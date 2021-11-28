Scorpio "AshToAsh.BlizzardSkin.Template" ""

local _Addon = _Addon

UI.Property             {
    name                = "UseParentLevel",
    type                = Boolean,
    require             = Frame,
    default             = false,
    set                 = function(self, val)
        if not val then return end
        local parent = self:GetParent()
        if parent then
            self:SetFrameLevel(parent:GetFrameLevel())
        end
    end
}

-- 选中
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinSelectionHighlightTexture")
class "SelectionHighlightTexture" { Texture }

-- 焦点
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinFocusTexture")
class "FocusTexture" { Texture }

-- 仇恨指示器
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinAggroHighlight")
class "AggroHighlight" { Texture }

-- 载具
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinVehicleIcon")
class "VehicleIcon" { Texture }

-- 死亡
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinDeadIcon")
class "DeadIcon" { Texture }

-- 团队拾取者
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinMasterLooterIcon")
class "MasterLooterIcon" { Texture }

-- 宠物面板标题
__Sealed__() __ChildProperty__(AshGroupPetPanel, "AshBlzSkinPanelLabel")
class "PetPanelLabel" { FontString }

-- 支持OmniCC的Cooldown
__Sealed__() __ChildProperty__(Frame, "OmniCCCooldown")
class "OmniCCCooldown"(function()
    inherit "Cooldown"

    property "HideCountdownNumbers" {
        type        = Boolean,
        default     = false,
        set         = function(self, hideCountdownNumbers)
            self:SetHideCountdownNumbers(hideCountdownNumbers)
            if OmniCC and OmniCC.Cooldown and OmniCC.Cooldown.SetNoCooldownCount then
                OmniCC.Cooldown.SetNoCooldownCount(self, hideCountdownNumbers)
            end
        end
    }

    function SetCooldown(self, ...)
        super.SetCooldown(self, ...)
        if not self.HideCountdownNumbers and OmniCC and OmniCC.Cooldown then
            OmniCC.Cooldown.OnSetCooldown(self, ...)
        end
    end

    function OnSetCooldownDuration(self, ...)
        super.SetCooldown(self, ...)
        if not self.HideCountdownNumbers and OmniCC and OmniCC.Cooldown then
            OmniCC.Cooldown.OnSetCooldownDuration(self, ...)
        end
    end

end)

__Sealed__() struct "LossOfControlData"   {
    { name = "lossOfControlText",   type = NEString },
    { name = "name",                type = NEString },
    { name = "icon",                type = Number   },
    { name = "duration",            type = Number   },
    { name = "expirationTime",      type = Number   }
}

-- 解锁按钮
__Sealed__() __ChildProperty__(AshGroupPanel, "AshBlzSkinUnlockButton")
class "UnlockButton"(function()
    inherit "Button"

    local function OnClick(self)
        if _Addon.UNLOCK_PANELS then
            LockPanels()
        else
            UnlockPanels()
        end
    end

    local function OnEnter(self)
        if not UnitAffectingCombat("player") then
            self:SetAlpha(100)
        end
    end

    local function OnLeave(self)
        self:SetAlpha(0)
    end

    function __ctor(self)
        self:SetAlpha(0)
        self.OnClick = self.OnClick + OnClick
        self.OnEnter = self.OnEnter + OnEnter
        self.OnLeave = self.OnLeave + OnLeave
    end
    
end)

-- EnlargeBuff icon
__Sealed__() class "AshBlzSkinEnlargeBuffIcon" { AshBlzSkinAuraIcon }

-- AuraPanel
class "BlzSkinAuraPanel"(function()
    inherit "AuraPanel"

    __Indexer__() __Observable__()
    property "AuraFilter" { set = Toolset.fakefunc }

    __Indexer__() __Observable__()
    property "AuraCaster" { set = Toolset.fakefunc }

end)

TEMPLATE_SKIN_STYLE                                                                     = {
    [BlzSkinAuraPanel]                                                                  = {
        refresh                                                                         = AshBlzSkinApi.UnitAura()
    },

    -- 目标选中边框
    [SelectionHighlightTexture]                                                         = {
        drawLayer                                                                       = "OVERLAY",
        subLevel                                                                        = 1,
        file                                                                            = "Interface\\RaidFrame\\Raid-FrameHighlights",
        texCoords                                                                       = RectType(0.00781250, 0.55468750, 0.28906250, 0.55468750),
        setAllPoints                                                                    = true,
        ignoreParentAlpha                                                               = true,
        visible                                                                         = Wow.UnitIsTarget()
    },

    -- 死亡图标
    [DeadIcon]                                                                          = {
        file                                                                            = "Interface\\EncounterJournal\\UI-EJ-Icons",
        texCoords                                                                       = RectType(0.375, 0.5, 0, 0.5),
        visible                                                                         = AshBlzSkinApi.UnitIsDead()
    },

    -- 解锁按钮
    [UnlockButton]                                                                      = {
        normalTexture                                                                   = {
            file                                                                        = "Interface\\Buttons\\LockButton-Locked-Up",
            setAllPoints                                                                = true
        },
        pushedTexture                                                                   = {
            file                                                                        = "Interface\\Buttons\\LockButton-Unlocked-Down",
            setAllPoints                                                                = true
        },
        highlightTexture                                                                = {
            file                                                                        = "Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight",
            alphaMode                                                                   = "ADD",
            setAllPoints                                                                = true
        }
    },

    -- Cooldown
    [OmniCCCooldown]                                                                    = {
        hideCountdownNumbers                                                            = AshBlzSkinApi.AuraHideCountdownNumbers(),
        setAllPoints                                                                    = true,
        reverse                                                                         = true,
        enableMouse                                                                     = false
    }
}

Style.UpdateSkin(SKIN_NAME, TEMPLATE_SKIN_STYLE)