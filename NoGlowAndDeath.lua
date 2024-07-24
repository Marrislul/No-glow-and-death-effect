local NoGlowAndDeath = LibStub("AceAddon-3.0"):NewAddon("NoGlowAndDeath", "AceConsole-3.0", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDB = LibStub("AceDB-3.0")

-- Default settings
local defaults = {
    profile = {
        PrintEnabled = true,
        GlowDisabled = true,
        DeathDisabled = true,
    },
}

-- Options table for AceConfig
local options = {
    name = "NoGlowAndDeath",
    handler = NoGlowAndDeath,
    type = "group",
    args = {
        GlowDisabled = {
            type = "toggle",
            name = "Disable Glow Effect",
            desc = "Enable or disable glow effects.",
            get = function(info) return NoGlowAndDeath.db.profile.GlowDisabled end,
            set = function(info, value) 
                NoGlowAndDeath.db.profile.GlowDisabled = value 
                NoGlowAndDeath:ApplySettings()
            end,
            order = 1,
        },
        DeathDisabled = {
            type = "toggle",
            name = "Disable Death Effect",
            desc = "Enable or disable death effects.",
            get = function(info) return NoGlowAndDeath.db.profile.DeathDisabled end,
            set = function(info, value) 
                NoGlowAndDeath.db.profile.DeathDisabled = value 
                NoGlowAndDeath:ApplySettings()
            end,
            order = 2,
        },
        PrintEnabled = {
            type = "toggle",
            name = "Enable Print Output",
            desc = "Enable or disable print output.",
            get = function(info) return NoGlowAndDeath.db.profile.PrintEnabled end,
            set = function(info, value) 
                NoGlowAndDeath.db.profile.PrintEnabled = value 
                NoGlowAndDeath:ApplySettings()
            end,
            order = 3,
        },
    },
}

function NoGlowAndDeath:OnInitialize()
    self.db = AceDB:New("NoGlowAndDeathDB", defaults, true)
    AceConfig:RegisterOptionsTable("NoGlowAndDeath", options)
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("NoGlowAndDeath", "NoGlowAndDeath")
end

function NoGlowAndDeath:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN", "ApplySettings")
end

function NoGlowAndDeath:ApplySettings()
    local settings = self.db.profile
    
    -- Apply the settings to CVars
    SetCVar("ffxDeath", settings.DeathDisabled and 0 or 1)
    SetCVar("ffxglow", settings.GlowDisabled and 0 or 1)
    
    -- Print confirmation if enabled
    if settings.PrintEnabled then
        self:Print("Settings applied.")
    end
end
