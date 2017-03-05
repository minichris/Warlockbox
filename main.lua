-------------------------------------------------------------------------------
-- Warlockbox demon and demon empowerment tracker by Zaperox
-- Based on ElvUI Wild Imps Tracker By Lockslap which in turn is
-- Based on Imps by Kuni!
-------------------------------------------------------------------------------
demonTime, demonEmpowered = {}, {}
local alreadyRegistered = false
local demonCount = 0
local empowered_demonCount = 0
local lastEnpowermentCast = 0
local petActive = 0
local petEmpowered = 0
local playerGUID
local CurrentDemon = "Succubus"
local EmpowermentTimeLeft = 0
local EmpowermentcastingTime = 1.5 --1.5 seconds is the default amount of time

local DemonicTable = {
    --Regular warlock pet codes
    ["1863"] = "Succubus",
    ["416"] = "Imp",
    ["58959"] = "Imp",
    ["1860"] = "Voidwalker",
    ["58960"] = "Voidwalker",
    ["417"] = "Felhunter",
    ["17252"] = "Felguard",
    ["11859"] = "Doomguard",
    ["89"] = "Infernal",
    ["58964"] = "Observer",
    ["58963"] = "Shivarra",
    ["58965"] = "Wrathguard",
    --Summoned pets
    ["55659"] = "Wild Imp",
    ["98035"] = "Dreadstalker",
    ["99737"] = "Wild Imp" -- the ones on top of dreadstalkers
    --Doomguard and infernal should be the same
}

local function ShowWindow(bool)
    if(Settings.HideOutOfCombat) then
        if(bool and InCombatLockdown()) then
            WarlockboxGUI:Show()
        else
            WarlockboxGUI:Hide()
        end
    else
        if(bool) then
            WarlockboxGUI:Show()
        else
            WarlockboxGUI:Hide()
        end
    end
end

local WarlockboxGUI = CreateFrame("Frame", "WarlockboxGUI", UIParent)
WarlockboxGUI:SetBackdrop({
	bgFile = "Interface\\dialogframe\\ui-dialogbox-background-dark",
	edgeFile = "Interface\\tooltips\\UI-tooltip-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 8,
	insets = {
		left = 1,
		right = 1,
		top = 1,
		bottom = 1,
	},
})
WarlockboxGUI:SetWidth(120)
WarlockboxGUI:SetHeight(30)
WarlockboxGUI:SetPoint("CENTER")
WarlockboxGUI:SetMovable(true)

-- imp artwork
local WarlockboxGUIImp = WarlockboxGUI:CreateTexture("impGraphic")
WarlockboxGUIImp:SetTexture("Interface\\AddOns\\Warlockbox\\"..CurrentDemon..".tga")
WarlockboxGUIImp:SetWidth(75)
WarlockboxGUIImp:SetHeight(75)
WarlockboxGUIImp:SetPoint("CENTER", -40, 0)
    
-- Empowerment artwork
local WarlockboxGUIEmpowerment = WarlockboxGUI:CreateTexture("impGraphic")
WarlockboxGUIEmpowerment:SetTexture("Interface\\Icons\\spell_warlock_demonicempowerment")
WarlockboxGUIEmpowerment:SetWidth(30)
WarlockboxGUIEmpowerment:SetHeight(30)
WarlockboxGUIEmpowerment:SetPoint("TOPRIGHT", 30, 0)
WarlockboxGUIEmpowerment:SetVertexColor(1, 1, 1, 1)

-- Countdown string
local demonCounter = WarlockboxGUI:CreateFontString("demonCounter")
demonCounter:SetFont("Interface\\AddOns\\Warlockbox\\Eggo.ttf", 24, "OUTLINE")
demonCounter:SetTextColor(1, 1, 1, 1)
demonCounter:SetText("0 / 0")
demonCounter:SetJustifyH("CENTER")
demonCounter:SetJustifyV("TOP")
demonCounter:SetPoint("RIGHT", WarlockboxGUI, -5, 0)

-- count string
local empowermentCountdown = WarlockboxGUI:CreateFontString("empowermentCountdown")
empowermentCountdown:SetFont("Interface\\AddOns\\Warlockbox\\Eggo.ttf", 18, "OUTLINE")
empowermentCountdown:SetTextColor(1, 1, 1, 1)
empowermentCountdown:SetText()
empowermentCountdown:SetJustifyH("CENTER")
empowermentCountdown:SetJustifyV("TOP")
empowermentCountdown:SetPoint("TOPRIGHT", WarlockboxGUI, 30, -8)
empowermentCountdown:Hide()

local function isDemonology()
	if (GetSpecialization() == 2) then
        return true
    else
        return false
    end
end

local function isWarlock()
    local _, class = UnitClass("player")
    if (class == "WARLOCK") then
        return true
    else
        return false
    end
end

local function RegisterifyAddon()
if (isWarlock() and (isDemonology() or not Settings.HideOutOfDemonology)) then
		if not alreadyRegistered then
			WarlockboxGUI:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			alreadyRegistered = true
			_, _, _, EmpowermentcastingTime = GetSpellInfo(193396)
		end
		ShowWindow(true)
	else
		if alreadyRegistered then
			WarlockboxGUI:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			alreadyRegistered = false
		end
		WarlockboxGUI:Hide()
	end
end

-- events
function WarlockboxGUI:CHARACTER_POINTS_CHANGED(self, event, ...)
	RegisterifyAddon()
end

function WarlockboxGUI:PLAYER_TALENT_UPDATE(self, event, ...)
	RegisterifyAddon()
end

function WarlockboxGUI:ACTIVE_TALENT_GROUP_CHANGED(self, event, ...)
	RegisterifyAddon()
end

function WarlockboxGUI:PLAYER_ENTERING_WORLD(self, event, ...)
	playerGUID = UnitGUID("player")
	
    if(Settings.UseEggo) then
        demonCounter:SetFont("Interface\\AddOns\\Warlockbox\\Eggo.ttf", 24, "OUTLINE")
    else 
        demonCounter:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
    end
    
    if (Settings.ShowIcon) then
        WarlockboxGUIImp:Show()
        WarlockboxGUI:SetWidth(120)
    else
        WarlockboxGUIImp:Hide()
        WarlockboxGUI:SetWidth(90)
    end
    
    ZapLib_FrameMoveable(Settings.Unlocked, WarlockboxGUI)
    
	-- only if they pass the checks will we actually look at the combat log
	if (isWarlock() and (isDemonology() or not Settings.HideOutOfDemonology)) then
		WarlockboxGUI:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		ShowWindow(true)
		alreadyRegistered = true
	else
		WarlockboxGUI:Hide()
	end
	
	-- events to watch to see if they switched to a demo spec
	WarlockboxGUI:RegisterEvent("CHARACTER_POINTS_CHANGED")
	WarlockboxGUI:RegisterEvent("PLAYER_TALENT_UPDATE")
	WarlockboxGUI:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	
	WarlockboxGUI:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function EmpowermentTickdown()
    if(EmpowermentTimeLeft > 0) then
        EmpowermentTimeLeft = EmpowermentTimeLeft - 0.25
        empowermentCountdown:SetText(ZapLib_DoubleDigit(floor(EmpowermentTimeLeft)))
		if(EmpowermentTimeLeft < EmpowermentcastingTime) then
			empowermentCountdown:SetTextColor(1,0,0);
        elseif(EmpowermentTimeLeft < (EmpowermentcastingTime * 2)) then
            empowermentCountdown:SetTextColor(1,1,0);
		else
			empowermentCountdown:SetTextColor(1,1,1);
		end
    else
        empowermentCountdown:SetText("")
        empowermentCountdown:Hide()
        WarlockboxGUIEmpowerment:SetVertexColor(1, 1, 1, 1)
    end
end
C_Timer.NewTicker(0.25, function() EmpowermentTickdown() end)

function WarlockboxGUI:COMBAT_LOG_EVENT_UNFILTERED(self, event, ...)  
    if(Settings.HideOutOfCombat and not InCombatLockdown()) then
        WarlockboxGUI:Hide()
    else
        WarlockboxGUI:Show()
    end

	local compTime = GetTime()
	local combatEvent = select(1, ...)
	local sourceGUID = select(3, ...)
	local destGUID = select(7, ...)
    local spellId = select(11, ...)
    local destNPCID = select(6,strsplit("-",destGUID))
    local DemonName = DemonicTable[destNPCID]
		
	-- time out any demons
	for index, value in pairs(demonTime) do
		if (value) < compTime then
			demonTime[index] = nil
			demonCount = demonCount - 1
            
			--print(("Demon timed out. Count: |cff00ff00%d|r"):format(demonCount))
		end
	end
	 
	-- demon died
	if combatEvent == "UNIT_DIED" then
		for index, value in pairs(demonTime) do
			if destGUID == index then
				demonTime[index] = nil
				demonCount = demonCount - 1
                
				--print(("Demon died. Count: |cff00ff00%d|r"):format(demonCount))
			end
		end
	end
    
    local function doEmpoweredDemonCount()
        empowered_demonCount = 0
        for index, value in pairs(demonTime) do
            if(demonEmpowered[index] ~= nil) then
                if(demonEmpowered[index] < GetTime() + 10) then
                    empowered_demonCount = empowered_demonCount + 1
                end
            end
        end
    end
    
    doEmpoweredDemonCount()
    
    -- player casts Demonic Empowerment
	if combatEvent == "SPELL_CAST_SUCCESS" and sourceGUID == UnitGUID("player") and spellId == 193396 then
        lastEnpowermentCast = GetTime()
        -- empower demons
        for index, value in pairs(demonTime) do
            demonEmpowered[index] = GetTime()
            --print("Demon empowered.")
        end
        doEmpoweredDemonCount()
        --Start the tickdown timer
        EmpowermentTimeLeft = 12
        WarlockboxGUIEmpowerment:SetVertexColor(0.5, 0.5, 0.5, 0.5)
        empowermentCountdown:Show()
	end
    
    -- unempower demons after 10 seconds
    for index, value in pairs(demonTime) do
        if(demonEmpowered[index] ~= nil) then --if not nil
            if(demonEmpowered[index] < GetTime() - 10) then
                demonEmpowered[index] = nil
                --print("Demon unempowered.")
            end
        end
    end
	
	-- imp summoned
	if combatEvent == "SPELL_SUMMON" and DemonName == "Wild Imp" and sourceGUID == playerGUID then
		demonTime[destGUID] = compTime + 12 --Imps last 12 seconds
        demonEmpowered[destGUID] = nil
		demonCount = demonCount + 1
		
		--print(("Imp spawned. Count: |cff00ff00%d|r"):format(demonCount))
        EmpowermentTimeLeft = 0
	end
    
    -- Dreadstalker summoned
	if combatEvent == "SPELL_SUMMON" and DemonName == "Dreadstalker" and sourceGUID == playerGUID then
		demonTime[destGUID] = compTime + 12 --Dreadstalkers last 12 seconds
        demonEmpowered[destGUID] = nil
		demonCount = demonCount + 1
        
		--print(("Dreadstalker spawned. Count: |cff00ff00%d|r"):format(demonCount))
        EmpowermentTimeLeft = 0
	end
    
    -- Doomguard summoned
	if combatEvent == "SPELL_SUMMON" and DemonName == "Doomguard" and sourceGUID == playerGUID and not IsSpellKnown(152107) then
		demonTime[destGUID] = compTime + 25 --Doomguard last 25 seconds
        demonEmpowered[destGUID] = nil
		demonCount = demonCount + 1
        
		--print(("Doomguard spawned. Count: |cff00ff00%d|r"):format(demonCount))
        EmpowermentTimeLeft = 0
	end
    
    -- Infernal summoned
	if combatEvent == "SPELL_SUMMON" and DemonName == "Infernal" and sourceGUID == playerGUID and not IsSpellKnown(152107) then
		demonTime[destGUID] = compTime + 25 --Infernal last 25 seconds
        demonEmpowered[destGUID] = nil
		demonCount = demonCount + 1
        
		--print(("Infernal spawned. Count: |cff00ff00%d|r"):format(demonCount))
        EmpowermentTimeLeft = 0
	end
    
    -- Darkglare summoned
	if combatEvent == "SPELL_SUMMON" and DemonName == "Darkglare" and sourceGUID == playerGUID then
		demonTime[destGUID] = compTime + 12 --Darkglare last 12 seconds
        demonEmpowered[destGUID] = nil
		demonCount = demonCount + 1
        
		--print(("Darkglare spawned. Count: |cff00ff00%d|r"):format(demonCount))
        EmpowermentTimeLeft = 0
	end
    
    -- Grimoire of Service summon
	if combatEvent == "SPELL_SUMMON" and sourceGUID == playerGUID then
		if(spellId == 111859 or spellId == 111897 or spellId == 111898 or spellId == 111896 or spellId == 111895) then --if it is a grimoire summon
            demonTime[destGUID] = compTime + 25 --Grimoire of Service summon last 25 seconds
            demonEmpowered[destGUID] = nil
            demonCount = demonCount + 1
            --print(("Grimoire of Service summon. Count: |cff00ff00%d|r"):format(demonCount))
            EmpowermentTimeLeft = 0
        end
	end
    
    -- if the warlock has a pet
    if(UnitExists("pet")) then
        petActive = 1
        
        local PetNPCID = select(6,strsplit("-",UnitGUID("pet")))
        CurrentDemon = DemonicTable[PetNPCID]
        
        if(CurrentDemon ~= nil) then --if its not a Enslaved demon
            WarlockboxGUIImp:SetWidth(75)
            WarlockboxGUIImp:SetHeight(75)
            if(CurrentDemon == "Fel Imp") then
                WarlockboxGUIImp:SetTexture("Interface\\AddOns\\Warlockbox\\Imp.tga")
            elseif(CurrentDemon == "Voidlord") then
                WarlockboxGUIImp:SetTexture("Interface\\AddOns\\Warlockbox\\Voidwalker.tga")
            else
                WarlockboxGUIImp:SetTexture("Interface\\AddOns\\Warlockbox\\"..CurrentDemon..".tga")
            end
        else
            WarlockboxGUIImp:SetWidth(37)
            WarlockboxGUIImp:SetHeight(37)
            WarlockboxGUIImp:SetTexture("Interface\\Icons\\spell_shadow_enslavedemon")
        end
        
        petEmpowered = 0
        for i = 1, 20 do
            local BuffID = select(11,UnitBuff("pet", i))
            if (BuffID == 193396) then
                petEmpowered = 1
            end
        end
        
    else
        petActive = 0
        petEmpowered = 0
    end
	
	demonCounter:SetText((demonCount + petActive.." / |cff00ff00%d|r"):format(empowered_demonCount + petEmpowered))
    
    --setting the players highscores
    if(Settings.HighestDemonCount < (demonCount + petActive)) then
        Settings.HighestDemonCount = demonCount + petActive
    end
    if(Settings.HighestEmpoweredCount < (empowered_demonCount + petEmpowered)) then
        Settings.HighestEmpoweredCount = empowered_demonCount + petEmpowered
    end
end

SlashCmdList['WARLOCKBOX_SLASHCMD'] = function(msg)
    if(msg == "demon toggle" or msg == "dt") then
        if (Settings.ShowIcon) then
            Settings.ShowIcon = false
            WarlockboxGUIImp:Hide()
            WarlockboxGUI:SetWidth(90)
            print("Demon icon toggled off.")
        else 
            Settings.ShowIcon = true
            WarlockboxGUIImp:Show()
            WarlockboxGUI:SetWidth(120)
            print("Demon icon toggled on.")
        end
    elseif(msg == "combat toggle" or msg == "ct") then
        if (Settings.HideOutOfCombat) then
            Settings.HideOutOfCombat = false
            print("The window will be shown out of combat.")
            WarlockboxGUI:Show()
        else 
            Settings.HideOutOfCombat = true
            print("The window will be hidden out of combat.")
            if(InCombatLockdown()) then
                WarlockboxGUI:Show()
            else
                WarlockboxGUI:Hide()
            end
        end
    elseif(msg == "lock toggle" or msg == "lt") then
        if (Settings.Unlocked) then
            Settings.Unlocked = false
            print("Box is now locked.")
        else 
            Settings.Unlocked = true
            print("Box is now unlocked")
        end
        ZapLib_FrameMoveable(Settings.Unlocked, WarlockboxGUI)
    elseif(msg == "spec toggle" or msg == "st") then
        if (Settings.HideOutOfDemonology) then
            Settings.HideOutOfDemonology = false
            print("Window will be shown in all specs.")
        else 
            Settings.HideOutOfDemonology = true
            print("Window will be hidden in other specs.")
        end
        RegisterifyAddon()
    elseif(msg == "font toggle" or msg == "ft") then
        if (Settings.UseEggo) then
            Settings.UseEggo = false
            print("Default font toggled on.")
            else 
            Settings.UseEggo = true
            print("Default font toggled off.")
        end
        print("You will need to /reload for the font to change.")
    else
        print("/wlb dt - Toggle the demon icon. Currently showing: "..ZapLib_BoolToString(Settings.ShowIcon))
        print("/wlb lt - Toggle the lock, allowing you to move the box. Currently locked: "..ZapLib_BoolToString(not Settings.Unlocked))
        print("/wlb ft - Change the font. Current font is default: "..ZapLib_BoolToString(not Settings.UseEggo))
        print("/wlb ct - Toggle if the window is shown out of combat. Currently hidden out of combat: "..ZapLib_BoolToString(Settings.HideOutOfCombat))
        print("/wlb st - Toggle the showing of the window when not in Demonology spec. Currently hidden out of spec: "..ZapLib_BoolToString(Settings.HideOutOfDemonology))
        print("Your highest ever amount of demons summoned at once is "..Settings.HighestDemonCount)
        print("Your highest ever amount of empowered demons at once is "..Settings.HighestEmpoweredCount)
    end
end
SLASH_WARLOCKBOX_SLASHCMD1 = '/wlb'
SLASH_WARLOCKBOX_SLASHCMD2 = '/warlockbox'

WarlockboxGUI:SetScript("OnEvent", function(self, event, ...)
    self[event](self, event, ...)
end)
WarlockboxGUI:RegisterEvent("PLAYER_ENTERING_WORLD")
WarlockboxGUI:RegisterEvent("PLAYER_LOGOUT")