-- Created by ManneN1
-- https://github.com/ManneN1/FeralCPs


-- Customize these for more Blizzard-like behaviour
-- No shine exists so it might look whacky

FERAL_COMBOFRAME_FADE_IN = 0;
FERAL_COMBOFRAME_FADE_OUT = 0;

---------------------------------------------------

local CPs
local feralbuilders = {
  [1822]   = 1, -- Rake
  [210722] = 3, -- Ashamane's Frenzy
  [5221]   = 1, -- Shred
  [155625] = 1, -- Moonfire
  [202060] = 5, -- Elune's Guidance
  [139546] = 1, -- Elune's Guidance Tick
  [16953]  = 1, -- Primal Fury (crits)
}

local feralfinishers = {
  [1079]  = true, -- Rip
  [22568] = true, -- Ferocious Bite
  [52610] = true, -- Savage Roar
}

local feralaoe = {
--[SPELLID] = {CP, TIME_SINCE}
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
  
  
  CPs = UnitPower(PlayerFrame.unit, 4);
  
  
	-- First hide uneccesary combo points
	for i = 7, 9 do
		FeralComboFrame.ComboPoints[i]:Hide();
    FeralComboFrame.ComboPoints[i].Highlight:SetAlpha(0);
	end
  FeralComboFrame.ComboPoints[1]:Hide()
  FeralComboFrame.ComboPoints[1].Highlight:SetAlpha(0);
  
  -- Init the necessary combo points
  for i = 2, 6 do
    FeralComboFrame.ComboPoints[i].Highlight:SetAlpha(0);
  end
  
  
  -- Show points
  ShowPoints(CPs);
  
  -- Register Events
	FeralComboFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
  FeralComboFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
  FeralComboFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
  

end

function FeralComboFrame_OnEvent(self, event, ...)
  if ( event == "PLAYER_TARGET_CHANGED" ) then
      local comboPoints = logCPs and CPs or UnitPower(PlayerFrame.unit, 4)
      ShowFeralComboFrame(comboPoints);     
  elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED") then
    local time, event,_,_,src,_,_,_,_ ,_,_,id = ...
    if (not src or not UnitIsUnit(src, PlayerFrame.unit)) then
      return
    end
    if ( event == "SPELL_ENERGIZE"  and feralbuilders[id] ~= nil ) then
      CPs = min(5, CPs + feralbuilders[id])
      ShowPoints(CPs)
   elseif ( event == "SPELL_CAST_SUCCESS" and feralfinishers[id]) then
     CPs = 0
     ShowPoints(CPs)
   elseif ( event == "SPELL_DAMAGE" and feralaoe[id]) then
     if (not feralaoe[id][2] or feralaoe[id][2] ~= time) then
       feralaoe[id][2] = time
       CPs = min(5, CPs + feralaoe[id][1])
       ShowPoints(CPs)
     end
   end
	elseif ( event == "UNIT_POWER_FREQUENT" ) then 
    unit, powertype = ... 
    if (powertype == "COMBO_POINTS" and unit == "player") then
      if ( UnitAffectingCombat("player") ) then
        return
      end
      local comboPoints = GetComboPoints(PlayerFrame.unit, "target");
      ShowPoints(comboPoints)
    end
  end
end

function ShowPoints(ComboPoints)
  local comboPoint; 
  ShowFeralComboFrame(ComboPoints);
  
  for i= 2, 6 do
      comboPoint = FeralComboFrame.ComboPoints[i];
      if ( comboPoint.Highlight:GetAlpha() == 1 and ComboPoints < i-1 ) then
        comboPoint.Highlight:SetAlpha(0)
      elseif ( comboPoint.Highlight:GetAlpha() ~= 1 and ComboPoints >= i-1 ) then
        comboPoint.Highlight:SetAlpha(1)
      end
  end
end

function ShowFeralComboFrame(comboPoints)
  FeralComboFrame.visible = FeralComboFrame.visible or false   
  if ( comboPoints > 0 and not FeralComboFrame.visible and UnitExists("target") ) then
    FeralComboFrame:Show()
    FeralComboFrame.visible = true
    UIFrameFadeIn(FeralComboFrame, FERAL_COMBOFRAME_FADE_IN)
  elseif ( FeralComboFrame.visible and ( comboPoints == 0 or not UnitExists("target") ) ) then
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
      print("disabling")
      if words[2] == "1" or words[2] == "2" then
        SetCVar("comboPointLocation", tonumber(words[2]), words[2])
        print("Changed CVAR")
        FeralComboFrame:Hide()
        FeralComboFrame:UnregisterAllEvents();
        ReloadUI();
      end
  end
end