Scorpio "AshToAsh.BlizzardSkin.Template.AuraContainer" ""

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

    property "ShowTooltip"      { type = Boolean, default = true }

    property "AuraIndex"        { type = Number }

    property "AuraFilter"       { type = String }

    property "AuraCaster"       { type = String }

    __Template__{
        Cooldown    = OmniCCCooldown,
        Icon        = Texture,
        Label       = FontString
    }
    function __ctor(self)
        self.OnEnter            = self.OnEnter + OnEnter
        self.OnLeave            = self.OnLeave + OnLeave
        self.OnUpdate           = self.OnUpdate + OnUpdate
    end
end)

-- Class buff icon
class "ClassBuffIcon" { AshBlzSkinCooldownAuraIcon }

-- Enlarge buff icon
class "EnlargeBuffIcon" { AshBlzSkinCooldownAuraIcon }

-- Boss Debuff icon
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
class "EnlargeDebuffIcon" { BossDebuffIcon }

__Sealed__()
class "AuraContainer"(function()

    local function GenerateAuraIcon(type, count)
        
    end

    property "BuffCount"            {
        type                        = NaturalNumber,
        default                     = 3
    }

    property "DebuffCount"          {
        type                        = NaturalNumber,
        default                     = 3
    }

    property "BossDebuffCount"      {
        type                        = NaturalNumber,
        default                     = 1
    }

    property "EnlargeDebuffCount"   {
        type                        = NaturalNumber,
        default                     = 2
    }

    property "EnlargeBuffCount"     {
        type                        = NaturalNumber,
        default                     = 2
    }

    property "DispelDebuffCount"    {
        type                        = NaturlNumber,
        default                     = 4
    }

    function __ctor(self)
        self.BuffIcons              = {}
        self.DebuffIcons            = {}
        self.BossDebuffIcons        = {}
        self.EnlargeDebuffIcons     = {}
        self.EnlargeBuffIcons       = {}
        self.DispelDebuffIcons      = {}
    end
end)

TEMPLATE_SKIN_STYLE                                                                     = {
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