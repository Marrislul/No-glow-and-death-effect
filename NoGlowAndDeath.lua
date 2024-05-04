-- Event handling frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LOGOUT")

-- Initialize global settings variable
_G.NoGlowAndDeath_Settings = _G.NoGlowAndDeath_Settings or { PrintEnabled = true, GlowDisabled = true, DeathDisabled = true }

-- Function to update the checkboxes based on the loaded settings
local function updateCheckboxes()
    NoGlowAndDeathPrintCheckBox:SetChecked(_G.NoGlowAndDeath_Settings.PrintEnabled)
    NoGlowAndDeathGlowCheckBox:SetChecked(_G.NoGlowAndDeath_Settings.GlowDisabled)
    NoGlowAndDeathDeathCheckBox:SetChecked(_G.NoGlowAndDeath_Settings.DeathDisabled)
end

-- Function to load and apply settings based on the current configuration
local function loadSettings()
    -- Apply the settings to CVars based on the inverted checkbox logic
    SetCVar("ffxDeath", _G.NoGlowAndDeath_Settings.DeathDisabled and 0 or 1)  -- Enable death effect if setting is true
    SetCVar("ffxglow", _G.NoGlowAndDeath_Settings.GlowDisabled and 0 or 1)   -- Enable glow effect if setting is true
    if _G.NoGlowAndDeath_Settings.PrintEnabled then
        print("NoGlowAndDeath: Settings applied.")
    end
end

-- Function to create the options panel
local function createOptionsPanel()
    local panel = CreateFrame("Frame", "NoGlowAndDeathPanel")
    panel.name = "NoGlowAndDeath"
    InterfaceOptions_AddCategory(panel)

    -- Title for the options panel
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("NoGlowAndDeath Settings")

    local checkBoxPrint = CreateFrame("CheckButton", "NoGlowAndDeathPrintCheckBox", panel, "UICheckButtonTemplate")
    checkBoxPrint:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
    checkBoxPrint:SetScript("OnClick", function(self)
        _G.NoGlowAndDeath_Settings.PrintEnabled = self:GetChecked()
        loadSettings()  -- Update settings immediately
    end)
    checkBoxPrint:SetChecked(_G.NoGlowAndDeath_Settings.PrintEnabled)
    checkBoxPrint.text = checkBoxPrint:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    checkBoxPrint.text:SetPoint("LEFT", checkBoxPrint, "RIGHT", 8, 0)
    checkBoxPrint.text:SetText("Enable Print Output")

    local checkBoxGlow = CreateFrame("CheckButton", "NoGlowAndDeathGlowCheckBox", panel, "UICheckButtonTemplate")
    checkBoxGlow:SetPoint("TOPLEFT", checkBoxPrint, "BOTTOMLEFT", 0, -8)
    checkBoxGlow:SetScript("OnClick", function(self)
        _G.NoGlowAndDeath_Settings.GlowDisabled = self:GetChecked()
        loadSettings()  -- Update settings immediately
    end)
    checkBoxGlow:SetChecked(_G.NoGlowAndDeath_Settings.GlowDisabled)
    checkBoxGlow.text = checkBoxGlow:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    checkBoxGlow.text:SetPoint("LEFT", checkBoxGlow, "RIGHT", 8, 0)
    checkBoxGlow.text:SetText("Disable Glow Effect")

    local checkBoxDeath = CreateFrame("CheckButton", "NoGlowAndDeathDeathCheckBox", panel, "UICheckButtonTemplate")
    checkBoxDeath:SetPoint("TOPLEFT", checkBoxGlow, "BOTTOMLEFT", 0, -8)
    checkBoxDeath:SetScript("OnClick", function(self)
        _G.NoGlowAndDeath_Settings.DeathDisabled = self:GetChecked()
        loadSettings()  -- Update settings immediately
    end)
    checkBoxDeath:SetChecked(_G.NoGlowAndDeath_Settings.DeathDisabled)
    checkBoxDeath.text = checkBoxDeath:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    checkBoxDeath.text:SetPoint("LEFT", checkBoxDeath, "RIGHT", 8, 0)
    checkBoxDeath.text:SetText("Disable Death Effect")
end


-- Create the options panel as soon as the addon is loaded
local optionsPanel = createOptionsPanel()

-- Event handling function
frame:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" and arg1 == "NoGlowAndDeath" then
        --print("NoGlowAndDeath loaded, printing is " .. (_G.NoGlowAndDeath_Settings.PrintEnabled and "enabled" or "disabled"))
    elseif event == "PLAYER_LOGIN" then
		updateCheckboxes()  -- Update checkboxes after loading settings
        loadSettings()  -- Load settings on login
    elseif event == "PLAYER_LOGOUT" then
        -- Settings are automatically saved by WoW
    end
end)