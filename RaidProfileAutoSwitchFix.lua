SLASH_SWITCHPROFILE1 = "/raidprofilefix"

SlashCmdList["TOGGLE_ENABLED"] = function(msg)
    RaidProfileAutoSwitchFixConfig.enabled = not RaidProfileAutoSwitchFixConfig.enabled
    if (RaidProfileAutoSwitchFixConfig.enabled) then
        print("RaidProfileAutoSwitchFix enabled")
    else
        print("RaidProfileAutoSwitchFix disabled")
    end
end

if not RaidProfileAutoSwitchFixConfig then
    RaidProfileAutoSwitchFixConfig = {
        enabled = true
    }
end

local function createOptionsPanel()
    local panel = CreateFrame("Frame", nil, UIParent)
    panel.name = "RaidProfileAutoSwitchFix"
    panel:Hide()

    panel.checkboxText = panel:CreateFontString("CheckboxString", "OVERLAY", "GameFontNormalLarge")
    panel.checkboxText:SetPoint("TOPLEFT", 40, -40)
    panel.checkboxText:SetText("Enabled")

    local toggle = CreateFrame("CheckButton", "Enabled", panel, "ChatConfigCheckButtonTemplate")
    toggle:SetPoint("TOPLEFT", 16, -36)
    toggle:SetChecked(RaidProfileAutoSwitchFixConfig.enabled)
    toggle:SetScript("OnClick", SlashCmdList["TOGGLE_ENABLED"])

    InterfaceOptions_AddCategory(panel, true)
end

function switchProfile(self, event, arg)
    if (event == "ADDON_LOADED" and arg == "RaidProfileAutoSwitchFix") then
        createOptionsPanel()
    end
    isArena, _ = IsActiveBattlefieldArena()
    if (not RaidProfileAutoSwitchFixConfig.enabled or not IsInGroup() or isArena) then
        return
    end

    local spec = GetSpecialization(false, false, 1)
    local _, numPlayers, _, enemyType = CompactUnitFrameProfiles_GetAutoActivationState()

    for i = 1, GetNumRaidProfiles() do
        local profile = GetRaidProfileName(i)
        if (CompactUnitFrameProfiles_ProfileMatchesAutoActivation(profile, numPlayers, spec, enemyType)) then
            CompactUnitFrameProfiles_ActivateRaidProfile(profile)
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED") --fires when player joins or leaves group
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", switchProfile)
