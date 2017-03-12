# FeralCPs

A WoW AddOn for accurate tracking of (Feral) Combo Points using the old (pre-Legion) ComboPoint frame.

In Legion the classic ComboPoint frame was replaced by a new ComboPoint frame, however many Ferals still like the old one, and it is
still available in the code (using CVar comboPointLocation) but with Legion it is riddled with bugs (Ferals have always been a bug filled spec), this
addon attempts to fix those issues by not using the default Blizzard Combo Point logic.

FeralCPs uses the event COMBAT_LOG_EVENT_UNFILTERED (sub-events DAMAGE_SUCCESS, SPELL_ENERGIZE and SPELL_CAST_SUCCESS), PLAYER_TARGET_CHANGED and UNIT_POWER_FREQUENT
to track your combo points accurately.

The "shine" fade-in has been removed in favour of faster response time!

# Warning

When disabling this AddOn you will need to either manually type (in-game chat) "/run SetCVar("comboPointLocation", X)", where X is replaced by either 1 or 2 depending on which
combo point frame you prefer (1 for Legion frame, 2 for default classic frame) OR you can type /fcp disable X before uninstalling/disabling the addon. Make sure your WoW folder is not
set to read-only as if so it will not save the updates.
# Usage

Chat commands: (/fcp & /feralcp)
  - enable
  - disable (mode)
  
Enabling or disabling will reload the UI. 

When disabling a new value for the comboPointLocation CVar has to be selected, valid options are 1 and 2.

The AddOn is automatically activated if the comboPointsLocation CVar is set to 0 (which it will be after using the enable command unless your WoW files are set to read-only).

If you want to change how long time a Combo Point takes to "appear" you can do so by modifying the constant variables at the top of the FeralCPs.lua file.
It might however look weird seeing as the default "shine" has been removed.

# Disclaimer

This AddOn will break your ComboPoints frame on fights like Malygos (last phase) and running the "/fcp disable 2" command is recommended before participating in fights
like these. I am not responsible for your wipes nor your broken UI when you uninstall this AddOn.

