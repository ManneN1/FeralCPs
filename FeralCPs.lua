-- Created by ManneN1
-- https://github.com/ManneN1/FeralCPs


-- Customize these for more Blizzard-like behaviour
-- No shine exists so it might look whacky

FERAL_COMBOFRAME_FADE_IN = 0;
FERAL_COMBOFRAME_FADE_OUT = 0;

---------------------------------------------------

local cps
local feralbuilders = {
  [1822]   = 1, -- Rake
  [274837] = 5, -- Feral Frenzy
  [5221]   = 1, -- Shred
  [155625] = 1, -- Moonfire (Feral)
  [16953]  = 1, -- Primal Fury (crits extra cps)
}

local feralfinishers = {
  [1079]  	= true, -- Rip
  [22568] 	= true, -- Ferocious Bite
  [52610] 	= true, -- Savage Roar
  [22570] 	= true, -- Maim
  [285381]	= true, -- Primal Wrath
}

local feralaoe = {
--[SPELLID] = {CP, TIME}
  [202028] = {1, 0}, -- Brutal Slash
  [106830] = {1, 0}, -- Thrash
  [106785] = {1, 0}, -- Swipe
}

---------------------------------------------------

function FeralComboFrame_OnLoad(self)
	print("FeralCPs loaded")
	init();
end

function init()
	
	if (GetCVar("comboPointLocation") ~= "0") then
		FeralComboFrame:Hide();
		return;
	else
		FeralComboFrame:Show();
	end
	
	
	cps = UnitPower(PlayerFrame.unit, 4);
	
	
	-- Init the necessary combo points
	for i = 1, 5 do
		FeralComboFrame.ComboPoints[i].Highlight:SetAlpha(0);
	end
  
	-- Show points
	ShowPoints(cps);
  
	-- Register Events
	FeralComboFrame:UnregisterAllEvents();
	FeralComboFrame:RegisterEvent("LOADING_SCREEN_DISABLED"); -- fixes some arena related combo point reset bug
	FeralComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
	FeralComboFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player");
	FeralComboFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	
end

function FeralComboFrame_OnEvent(self, event, ...)
	
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		
		cps = cps or UnitPower(PlayerFrame.unit, 4)
		ShowPoints(cps);     

	elseif ( event == "LOADING_SCREEN_DISABLED") then

		-- Sometimes cps reset (entering arenas for example) after loading screen
		cps = min(cps, UnitPower(PlayerFrame.unit, 4))
		ShowPoints(cps);

	elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED") then

		local time, event,_,_,src,_,_,_,_ ,_,_,id = CombatLogGetCurrentEventInfo()
		
		if (not src or not UnitIsUnit(src, PlayerFrame.unit)) then
			return
		end
		
		if ( (event == "SPELL_CAST_SUCCESS") and feralbuilders[id] ~= nil ) then

			cps = min(5, cps + feralbuilders[id])
			ShowPoints(cps)

		elseif ( event == "SPELL_CAST_SUCCESS" and feralfinishers[id]) then

			cps = 0
			ShowPoints(cps)

		elseif ( event == "SPELL_DAMAGE" and feralaoe[id]) then
	
			if (not feralaoe[id][2] or feralaoe[id][2] ~= time) then

				feralaoe[id][2] = time
				cps = min(5, cps + feralaoe[id][1])
				ShowPoints(cps)
			
			end
		
		end
	elseif ( event == "UNIT_POWER_UPDATE" ) then 
		
		-- You drop combo points out of combat (one every 30 seconds)
		if ( UnitAffectingCombat("player") ) then
				return
			end
		
		unit, powertype = ... 
		
		if (powertype == "COMBO_POINTS" and unit == PlayerFrame.unit) then
			if (UnitPower(PlayerFrame.unit, 4) < cps) then

				cps = UnitPower(PlayerFrame.unit, 4);
				ShowPoints(cps)
			end
		end
	end
end

function ShowPoints(cps)

	ShowFeralComboFrame(cps);
	
	local comboPointFrame
  
	for i=1,5 do
		
		comboPointFrame = FeralComboFrame.ComboPoints[i];
		
		if ( comboPointFrame.Highlight:GetAlpha() == 1 and cps < i-1 ) then
		
			comboPointFrame.Highlight:SetAlpha(0)
		
		elseif ( comboPointFrame.Highlight:GetAlpha() ~= 1 and cps >= i-1 ) then
		
			comboPointFrame.Highlight:SetAlpha(1)
		
		end
		
	end
	
end

function ShowFeralComboFrame(cps)
	
	FeralComboFrame.visible = FeralComboFrame.visible or false   
	
	if ( cps > 0 and not FeralComboFrame.visible and UnitExists("target") ) then
	
		FeralComboFrame:Show()
		FeralComboFrame.visible = true
		UIFrameFadeIn(FeralComboFrame, FERAL_COMBOFRAME_FADE_IN)
	
	elseif ( FeralComboFrame.visible and ( cps == 0 or not UnitExists("target") ) ) then
	
		FeralComboFrame:Hide()
		FeralComboFrame.visible = false
		UIFrameFadeOut(FeralComboFrame, FERAL_COMBOFRAME_FADE_OUT)
		
	end
	
end

SLASH_FERALCP1, SLASH_FERALCP2 = '/feralcp', '/fcp'; 
function SlashCmdList.FERALCP(msg, editbox)
	
	msg = string.lower(msg)
	
	if msg:trim() == "enable" then
		
		if (GetCVar("comboPointLocation") ~= 0) then
		
			SetCVar("comboPointLocation", 0);
			ReloadUI();
		
		end
		
	end
	
	local words = {}
	for word in msg:gmatch("%w+") do table.insert(words, word) print(word) end
	
	if words[1] == "disable" then
		
		if words[2] == "1" or words[2] == "2" then
			
			print("Disabling FCP")
			SetCVar("comboPointLocation", tonumber(words[2]), words[2])
			FeralComboFrame:Hide()
			FeralComboFrame:UnregisterAllEvents();
			ReloadUI();
			
		else
			print("You did not add a new position for the combo point frame, select 1 for target and 2 for player.")
		end
		
	end
end
