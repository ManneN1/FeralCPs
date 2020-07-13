-- Created by ManneN1
-- https://github.com/ManneN1/FeralCPs


-- Customize these for more Blizzard-like behaviour
-- There's no shine so it might look whacky

FERAL_COMBOFRAME_FADE_IN = 0;
FERAL_COMBOFRAME_FADE_OUT = 0;

---------------------------------------------------

local cps
local feralabilities = {
  [1822]   = {subEvents = {["SPELL_ENERGIZE"] = true}, comboPoints = 1}, 										-- Rake
  [274838] = {subEvents = {["SPELL_ENERGIZE"] = true}, comboPoints = 1}, 										-- Feral Frenzy
  [5221]   = {subEvents = {["SPELL_ENERGIZE"] = true}, comboPoints = 1}, 										-- Shred
  [155625] = {subEvents = {["SPELL_ENERGIZE"] = true}, comboPoints = 1}, 										-- Moonfire (Feral)
  [16953]  = {subEvents = {["SPELL_ENERGIZE"] = true}, comboPoints = 1},						 				-- Primal Fury (crits extra cps)
  [279471] = {subEvents = {["SPELL_ENERGIZE"] = true}, comboPoints = 1}, 										-- Gushing Laceration (Rip Azerite Trait)
  [1079]   = {subEvents = {["SPELL_AURA_APPLIED"] = true, ["SPELL_AURA_REFRESH"] = true}, comboPoints = -5}, 	-- Rip										-- Rip
  [22568]  = {subEvents = {["SPELL_DAMAGE"] = true, ["SPELL_ABSORBED"] = true}, comboPoints = -5},			 	-- Ferocious Bite
  [52610]  = {subEvents = {["SPELL_AURA_APPLIED"] = true, ["SPELL_AURA_REFRESH"] = true}, comboPoints = -5}, 	-- Savage Roar
  [22570]  = {subEvents = {["SPELL_DAMAGE"] = true, ["SPELL_ABSORBED"] = true}, comboPoints = -5}, 				-- Maim
  [285381] = {subEvents = {["SPELL_CAST_SUCCESS"] = true}, comboPoints = -5}, 									-- Primal Wrath
  [202028] = {subEvents = {["SPELL_DAMAGE"] = true, ["SPELL_ABSORBED"] = true}, comboPoints = 1, time = 0}, 	-- Brutal Slash
  [106830] = {subEvents = {["SPELL_DAMAGE"] = true, ["SPELL_ABSORBED"] = true}, comboPoints = 1, time = 0}, 	-- Thrash
  [106785] = {subEvents = {["SPELL_DAMAGE"] = true, ["SPELL_ABSORBED"] = true}, comboPoints = 1, time = 0},	 	-- Swipe
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

		local t, event,_,_,src,_,_,_,_ ,_,_,id,name = CombatLogGetCurrentEventInfo()
		
		if (not src or not UnitIsUnit(src, PlayerFrame.unit)) then
			return
		end
		
		-- DEBUG
		--if (strfind(event, "SPELL") and (feralabilities[id] ~= nil) and not strfind(event, "PERIODIC")) then
		--	print(event)
		--	print(id)
		--	print(name)
		--end
		
		if feralabilities[id] and feralabilities[id].subEvents[event] and 
			((feralabilities[id].time ~= nil and feralabilities[id].time ~= t) 
				or feralabilities[id].time == nil) then
			
			if (feralabilities[id].time ~= nil) then 
				feralabilities[id].time = t 
			end
			
			cps = max(0, min(5, cps + feralabilities[id].comboPoints))
			ShowPoints(cps)
		
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
		
		if ( comboPointFrame.Highlight:GetAlpha() == 1 and cps < i ) then
		
			comboPointFrame.Highlight:SetAlpha(0)
		
		elseif ( comboPointFrame.Highlight:GetAlpha() ~= 1 and cps >= i ) then
		
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
	local words = {}
	for word in msg:gmatch("%w+") do table.insert(words, word) end
	
	if msg:trim() == "enable" then
		
		if (GetCVar("comboPointLocation") ~= 0) then
		
			SetCVar("comboPointLocation", 0);
			ReloadUI();
		
		end
		
	elseif words[1] == "disable" then
	 	
		if words[2] == "1" or words[2] == "2" then
			
			print("Disabling FCP")
			SetCVar("comboPointLocation", tonumber(words[2]))
			FeralComboFrame:Hide()
			FeralComboFrame:UnregisterAllEvents();
			ReloadUI();
			
		else
			print("You did not add a new position for the combo point frame, select 1 for target and 2 for player.")
		end
	else
		print("Valid commands include: enable, disable x.(where x is a number either 1 or 2)")
	end
end
