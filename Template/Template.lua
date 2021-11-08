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

__Sealed__() class "AshBlzSkinAuraIcon"(function(_ENV)
    inherit "Frame"

    local function OnEnter(self)
        if self.ShowTooltip and self.AuraIndex then
            local parent        = self:GetParent()
            if not parent then return end

            GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
            GameTooltip:SetUnitAura(parent.Unit, self.AuraIndex, self.AuraFilter)
        end
    end

    local function OnUpdate(self, elapsed)
        self.timer = (self.timer or 0) + elapsed
        if self.timer < 0.5 then
            return
        end
        self.timer = 0

        local parent        = self:GetParent()
        if not parent then return end
        if self.ShowTooltip and GameTooltip:IsOwned(self) then
            GameTooltip:SetUnitAura(parent.Unit, self.AuraIndex, self.AuraFilter)
        end
    end

    local function OnLeave(self)
        GameTooltip:Hide()
    end

    property "ShowTooltip"      { type = Boolean, default = true }

    property "AuraIndex"        { type = Number }

    property "AuraFilter"       { type = String }

    property "AuraCaster"       { type = String }

    __Template__{
        
    }
    function __ctor(self)
        self.OnEnter            = self.OnEnter + OnEnter
        self.OnLeave            = self.OnLeave + OnLeave
        self.OnUpdate           = self.OnUpdate + OnUpdate
    end
end)


__Sealed__() struct "AuraData" {
    { name = "Index"            },
    { name = "Name"             },
    { name = "Icon"             },
    { name = "Count"            },
    { name = "DebuffType"       },
    { name = "Cooldown"         },
    { name = "Stealeable"       },
    { name = "Caster"           },
    { name = "SpellID"          },
    { name = "IsBossAura"       },
    { name = "CasterByPlayer"   },
    { name = "Filter"           },
    { name = "Duration"         },
    { name = "ExpirationTime"   }
}

__Sealed__()
class "AshBlzSkinCooldownAuraIcon"(function()
    inherit "AshBlzSkinAuraIcon"

    property "AuraData" { 
        type        = AuraData,
        set         = function(self, data)
            if data then
                self:SetAuraData(data)
                self:Show()
            else
                self:Hide()
            end
        end
    }

    function SetAuraData(self, data)
        self.AuraIndex = data.Index
        self.AuraFilter = data.Filter
        self.AuraCaster = data.Caster
        self:SetIcon(data.Icon)
        self:SetLabel(data.Count)
        self:GetChild("Cooldown"):SetCooldown(data.ExpirationTime - data.Duration, data.Duration)
    end

    function SetLabel(self, auraCount)
        local label = auraCount
        if auraCount >= 100 then
            label = BUFF_STACKS_OVERFLOW
        elseif auraCount <=0 then
            label = ""
        end
        self:GetChild("Label"):SetText(label)
    end

    function SetIcon(self, icon)
        self:GetChild("Icon"):SetTexture(icon)
    end

    __Template__{
        Cooldown    = OmniCCCooldown,
        Icon        = Texture,
        Label       = FontString
    }
    function __ctor(self)
    end
end)

-- Class buff icon
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinClassBuffIcon")
class "ClassBuffIcon" { AshBlzSkinCooldownAuraIcon }

-- Enlarge buff icon
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinEnlargeBuffIcon")
class "EnlargeBuffIcon" { AshBlzSkinCooldownAuraIcon }

-- Boss Debuff icon
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinBossDebuffIcon")
class "BossDebuffIcon"(function()
    inherit "AshBlzSkinCooldownAuraIcon"

    function SetAuraData(self, data)
        super.SetAuraData(self, data)
        local color = DebuffTypeColor[data.DebuffType or ""]
        self:GetChild("Background"):SetVertexColor(color.r, color.g, color.b, color.a)
    end

    __Template__{
        Background      = Texture
    }
    function __ctor(self)
    end
end)

-- EnlargeDebuff icon
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinEnlargeDebuffIcon")
class "EnlargeDebuffIcon" { BossDebuffIcon }

-- Buff icon
__Sealed__()
class "AshBlzSkinBuffIcon"(function()
    inherit "AshBlzSkinAuraIcon"

    local function OnMouseUp(self, button)
        local parent            = self:GetParent()
        if not parent then return end
        if IsAltKeyDown() and button == "RightButton" then
            local name, _, _, _, _, _, _, _, _, spellID = UnitAura(parent.Unit, self.AuraIndex, self.AuraFilter)

            if name then
                _AuraBlackList[spellID] = true
                FireSystemEvent("ASHTOASH_CONFIG_CHANGED")

                -- Force the refreshing
                Next(Scorpio.FireSystemEvent, "UNIT_AURA", "any")
            end
        elseif IsControlKeyDown() and button == "LeftButton" and self.AuraFilter:match("HARMFUL") then
            local name, _, _, _, _, _, _, _, _, spellID = UnitAura(parent.Unit, self.AuraIndex, self.AuraFilter)

            if name then
                _EnlargeDebuffList[spellID] = true
                FireSystemEvent("ASHTOASH_CONFIG_CHANGED")

                -- Force the refreshing
                Next(Scorpio.FireSystemEvent, "UNIT_AURA", "any")
            end
        end
    end

    function __ctor(self)
        super(self)
        self.OnMouseUp = OnMouseUp
    end

end)

-- Debuff icon
__Sealed__()
class "AshBlzSkinDebuffIcon" { AshBlzSkinBuffIcon }

-- Dispell icon
__Sealed__()
class "AshBlzSkinDispellIcon" { AshBlzSkinAuraIcon }

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

-- DispellDebuff Panel
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinDispellDebuffPanel")
class "DispellDebuffPanel" (function(_ENV)
    inherit "BlzSkinAuraPanel"

    local shareCooldown         = { start = 0, duration = 0 }
    local dispellDebuffs        = {}
    -- 可驱散Debuff类型
    local dispellDebuffTypes    = { Magic = true, Curse = true, Disease = true, Poison = true }

    local function refreshAura(self, unit, filter, eleIdx, auraIdx, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        if not name or eleIdx > self.MaxCount then return eleIdx end

        if dispellDebuffTypes[dtype] and not dispellDebuffs[dtype] then
            dispellDebuffs[dtype]           = true

            self.Elements[eleIdx]:Show()

            shareCooldown.start             = expires - duration
            shareCooldown.duration          = duration

            self.AuraIndex[eleIdx]          = auraIdx
            self.AuraName[eleIdx]           = name
            self.AuraIcon[eleIdx]           = icon
            self.AuraCount[eleIdx]          = count
            self.AuraDebuff[eleIdx]         = dtype
            self.AuraCooldown[eleIdx]       = shareCooldown
            self.AuraStealable[eleIdx]      = isStealable and not UnitIsUnit(unit, "player")
            self.AuraCaster[eleIdx]         = caster
            self.AuraSpellID[eleIdx]        = spellID
            self.AuraBossDebuff[eleIdx]     = isBossAura
            self.AuraCastByPlayer[eleIdx]   = castByPlayer
            self.AuraFilter[eleIdx]         = filter

            eleIdx = eleIdx + 1
        end
        
        auraIdx = auraIdx + 1
        return refreshAura(self, unit, filter, eleIdx, auraIdx, UnitAura(unit, auraIdx, filter))
    end

    property "Refresh"          {
        set                     = function(self, unit)
            self.Unit           = unit
            if not (unit and self:IsVisible()) then self.Count = 0 return end

            wipe(dispellDebuffs)
            
            local filter        = "HARMFUL|RAID"
            self.Count          = refreshAura(self, unit, filter, 1, 1, UnitAura(unit, 1, filter)) - 1
        end
    }

    -- we don't care about priority in dispell panel
    property "AuraPriority"     { set = false }

    property "CustomFilter"     { set = false }

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
    },

    -- AuraIcon
    [AshBlzSkinAuraIcon]                                                                = {
        enableMouse                                                                     = AshBlzSkinApi.AuraTooltipEnable(),
        
        auraIndex                                                                       = Wow.FromPanelProperty("AuraIndex"),
        auraFilter                                                                      = Wow.FromPanelProperty("AuraFilter"),
        
        IconTexture                                                                     = {
            drawLayer                                                                   = "ARTWORK",
            setAllPoints                                                                = true,
            file                                                                        = Wow.FromPanelProperty("AuraIcon"),
        },

        Label                                                                           = {
            drawLayer                                                                   = "OVERLAY",
            fontObject                                                                  = NumberFontNormalSmall,
            location                                                                    = {
                Anchor("BOTTOMRIGHT", 0, 0)
            },
            text                                                                        = Wow.FromPanelProperty("AuraCount"):Map(function(val)
                if val >= 100 then
                    return BUFF_STACKS_OVERFLOW
                elseif val > 1 then
                    return val
                else
                    return ""
                end
            end),
        },

        OmniCCCooldown                                                                  = {
            cooldown                                                                    = Wow.FromPanelProperty("AuraCooldown")
        },
    },

    -- 自带冷却组件的AuraIcon
    [AshBlzSkinCooldownAuraIcon]                                                        = {
        enableMouse                                                                     = AshBlzSkinApi.AuraTooltipEnable(),

        Icon                                                                            = {
            drawLayer                                                                   = "ARTWORK",
            setAllPoints                                                                = true,
        },

        Label                                                                           = {
            drawLayer                                                                   = "OVERLAY",
            fontObject                                                                  = NumberFontNormalSmall,
            location                                                                    = {
                Anchor("BOTTOMRIGHT", 0, 0)
            }
        }
    },

    -- Buff icon
    [AshBlzSkinBuffIcon]                                                                = {
        alpha                                                                           = Wow.FromPanelProperty("AuraCaster"):Map(function(caster)
            return UnitExists(caster) and (UnitIsUnit("player", caster) and 1 or 0.5) or 1
        end)
    },

    -- DebuffIcon
    [AshBlzSkinDebuffIcon]                                                              = {
        alpha                                                                           = NIL,

        BackgroundTexture                                                               = {
            drawLayer                                                                   = "OVERLAY",
            file                                                                        = "Interface\\Buttons\\UI-Debuff-Overlays",
            location                                                                    = {
                Anchor("TOPLEFT", -1, 1),
                Anchor("BOTTOMRIGHT", 1, -1)
            },
            texCoords                                                                   = RectType(0.296875, 0.5703125, 0, 0.515625),
            vertexColor                                                                 = Wow.FromPanelProperty("AuraDebuff"):Map(function(dtype) return DebuffTypeColor[dtype or ""] end)
        },
    },

    -- Dispell icon
    [AshBlzSkinDispellIcon]                                                             = {
        IconTexture                                                                     = {
            drawLayer                                                                   = "ARTWORK",
            setAllPoints                                                                = true,
            file                                                                        = Wow.FromPanelProperty("AuraDebuff"):Map(function(dtype)
                return "Interface\\RaidFrame\\Raid-Icon-Debuff"..dtype
            end),
            texCoords                                                                   = RectType(0.125, 0.875, 0.125, 0.875)
        },

        OmniCCCooldown                                                                  = NIL
    },

    -- Class buff icon
    [ClassBuffIcon]                                                                     = {
        auraData                                                                        = AshBlzSkinApi.UnitClassBuff(),
        enableMouse                                                                     = false
    },

    -- Boss debuff icon
    [BossDebuffIcon]                                                                    = {
        auraData                                                                        = AshBlzSkinApi.UnitBossDebuff(),

        Background                                                                      = {
            drawLayer                                                                   = "OVERLAY",
            file                                                                        = "Interface\\Buttons\\UI-Debuff-Overlays",
            location                                                                    = {
                Anchor("TOPLEFT", -1, 1),
                Anchor("BOTTOMRIGHT", 1, -1)
            },
            texCoords                                                                   = RectType(0.296875, 0.5703125, 0, 0.515625)
        },
    },

    -- Enlarge debuff icon
    [EnlargeDebuffIcon]                                                                 = {
        topLevel                                                                        = true,
        auraData                                                                        = AshBlzSkinApi.UnitEnlargeDebuff(),

        PixelGlow                                                                       = {
            period                                                                      = 2,
            visible                                                                     = true
        }
    },

    -- Enlarge buff icon
    [EnlargeBuffIcon]                                                                   = {
        topLevel                                                                        = true,
        auraData                                                                        = AshBlzSkinApi.UnitEnlargeBuff(),
    }
}

Style.UpdateSkin(SKIN_NAME, TEMPLATE_SKIN_STYLE)