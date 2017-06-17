defaults = {
    ShowIcon = true,
    Unlocked = true,
    UseEggo = false,
    HighestDemonCount = 0,
    HighestEmpoweredCount = 0,
    HideOutOfCombat = false,
    HideOutOfDemonology = true,
	HighestConsumptionCount = 0,
	HighestEmpoweredConsumptionCount = 0
}

local frame = CreateFrame("FRAME"); -- Need a frame to respond to events
frame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
frame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out

function frame:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Warlockbox" then
        if(WARLOCKBOX_SETTINGS == nil) then
            WARLOCKBOX_SETTINGS = defaults;
        end
        Settings = WARLOCKBOX_SETTINGS;
        
        --Update 0.32 added setting section
        if((Settings.HighestDemonCount == nil) or (Settings.HighestEmpoweredCount == nil)) then
            Settings.HighestDemonCount = 0
            Settings.HighestEmpoweredCount = 0
        end
        
        --Update 0.33 added setting section
        if(Settings.HideOutOfCombat == nil) then
            Settings.HideOutOfCombat = false
        end
        
        if(Settings.HideOutOfDemonology == nil) then
            Settings.HideOutOfDemonology = true
        end
		
		--Update 0.36 added setting section
		if(Settings.HighestConsumptionCount == nil) then
            Settings.HighestConsumptionCount = 0
        end

		if(Settings.HighestEmpoweredConsumptionCount == nil) then
            Settings.HighestEmpoweredConsumptionCount = 0
        end
    elseif event == "PLAYER_LOGOUT" then
        WARLOCKBOX_SETTINGS = Settings;
    end
end
frame:SetScript("OnEvent", frame.OnEvent);