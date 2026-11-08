-- WoW Forever version. Forever's new lighting ignores ffxGlow, the glow there is bloom.
-- The game has its own slider for it: Bloom Intensity (CVar bloomUserMult, 0 to 1).
-- The glow option follows that slider: bloom at 0 = ticked, anything above 0 = unticked.
local NoGlowAndDeath = LibStub("AceAddon-3.0"):NewAddon("NoGlowAndDeath", "AceConsole-3.0", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceDB = LibStub("AceDB-3.0")

local BLOOM_CVAR = "bloomUserMult"
local BLOOM_MAX = 1

-- Default settings
local defaults = {
    profile = {
        PrintEnabled = true,
        GlowDisabled = true,
        DeathDisabled = true,
        -- BloomApplied: the addon has set bloom to 0 before, so bloom above 0 at login means the player turned it up
    },
}

local function GetBloom()
    return tonumber(C_CVar.GetCVar(BLOOM_CVAR))
end

-- Options table for AceConfig
local options = {
    name = "NoGlowAndDeath",
    handler = NoGlowAndDeath,
    type = "group",
    args = {
        GlowNote = {
            type = "description",
            name = "|cffffd100Note:|r WoW Forever now has its own slider for the glow: Bloom Intensity in the graphics settings.",
            order = 0,
        },
        GlowDisabled = {
            type = "toggle",
            name = "Disable Glow Effect",
            desc = "Sets Bloom Intensity to 0. Unticking sets it to max. Turning bloom up in the game's settings unticks this.",
            get = function(info) return NoGlowAndDeath.db.profile.GlowDisabled end,
            set = function(info, value)
                NoGlowAndDeath:SetGlowDisabled(value)
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
    self:RegisterEvent("PLAYER_LOGIN", "OnLogin")
    self:RegisterEvent("CVAR_UPDATE")
end

function NoGlowAndDeath:OnLogin()
    local settings = self.db.profile
    local bloom = GetBloom()
    -- Bloom was turned up while the addon wasn't watching (e.g. with the addon disabled)
    if settings.GlowDisabled and settings.BloomApplied and bloom and bloom > 0 then
        settings.GlowDisabled = false
    end
    self:ApplySettings()
end

function NoGlowAndDeath:ApplySettings()
    local settings = self.db.profile

    SetCVar("ffxDeath", settings.DeathDisabled and 0 or 1)
    -- With the glow option off, the game's slider stays as the player set it
    if settings.GlowDisabled then
        self:DisableBloom()
    end

    -- Print confirmation if enabled
    if settings.PrintEnabled then
        self:Print("Settings applied.")
    end
end

function NoGlowAndDeath:DisableBloom()
    self.db.profile.BloomApplied = true
    SetCVar(BLOOM_CVAR, 0)
end

function NoGlowAndDeath:SetGlowDisabled(value)
    local settings = self.db.profile
    if value == settings.GlowDisabled then return end
    settings.GlowDisabled = value

    -- Turning it on is handled by ApplySettings. Turning it off sets bloom to max.
    if not value then
        SetCVar(BLOOM_CVAR, BLOOM_MAX)
    end
end

-- Keeps the tick in sync when the player moves the game's slider (also fires for the addon's own SetCVar calls).
function NoGlowAndDeath:CVAR_UPDATE(event, name, value)
    if not name or name:lower() ~= BLOOM_CVAR:lower() then return end
    local bloom = tonumber(value)
    if not bloom then return end

    local settings = self.db.profile
    if bloom > 0 then
        settings.GlowDisabled = false
    else
        settings.GlowDisabled = true
        settings.BloomApplied = true
    end
    AceConfigRegistry:NotifyChange("NoGlowAndDeath")
end
