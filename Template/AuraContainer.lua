Scorpio "AshToAsh.BlizzardSkin.Template.AuraContainer" ""

__Sealed__() struct "AuraData" {
    { name = "Unit"             },
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
class "AuraIcon"(function()
    inherit "Frame"

    local function OnEnter(self)
        if self.ShowTooltip and self.AuraIndex then
            GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
            GameTooltip:SetUnitAura(self.Unit, self.AuraIndex, self.AuraFilter)
        end
    end

    local function OnUpdate(self, elapsed)
        self.timer = (self.timer or 0) + elapsed
        if self.timer < 0.5 then
            return
        end
        self.timer = 0

        if self.ShowTooltip and GameTooltip:IsOwned(self) then
            GameTooltip:SetUnitAura(self.Unit, self.AuraIndex, self.AuraFilter)
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

-- Buff icon
class "BuffIcon"(function()
    inherit "AuraIcon"

    local function OnMouseUp(self, button)
        if IsAltKeyDown() and button == "RightButton" then
            local name, _, _, _, _, _, _, _, _, spellID = UnitAura(self.Unit, self.AuraIndex, self.AuraFilter)

            if name then
                _AuraBlackList[spellID] = true
                FireSystemEvent("ASHTOASH_CONFIG_CHANGED")

                -- Force the refreshing
                Next(Scorpio.FireSystemEvent, "UNIT_AURA", "any")
            end
        elseif IsControlKeyDown() and button == "LeftButton" and self.AuraFilter:match("HARMFUL") then
            local name, _, _, _, _, _, _, _, _, spellID = UnitAura(self.Unit, self.AuraIndex, self.AuraFilter)

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
class "DebuffIcon"(function()
    inherit "BuffIcon"

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

-- Boss Debuff icon
class "BossDebuffIcon" { DebuffIcon }

-- Class buff icon
class "ClassBuffIcon" { AuraIcon }

-- Enlarge buff icon
class "EnlargeBuffIcon" { AuraIcon }

-- Enlarge Debuff icon
class "EnlargeDebuffIcon" { DebuffIcon }

__Sealed__()
class "AuraContainer"(function()

    local AuraTypes = {
        Buff                        = true,
        Debuff                      = true,
        BossDebuff                  = true,
        EnlargeDebuff               = true,
        EnlargeBuff                 = true,
        DispelDebuff                = true,
        ClassBuff                   = true
    }

    local function GenerateAuraIcon(type, count)
        local icons = self[type .. "Icons"]
        for i = 1, count do
            if not icons[i] then
                -- local icon = 
            end
        end
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
        default                     = 1,
        set                         = Toolset.fakefunc
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
        for _, auraType in pairs(AuraTypes) do
            self[auraType .. "Icons"] = {}
        end
    end
end)

TEMPLATE_SKIN_STYLE                                                                     = {
    -- 自带冷却组件的AuraIcon
    [AuraIcon]                                                                          = {
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
        topLevel                                                                        = true,
        enableMouse                                                                     = false
    },

    -- Debuff icon
    [DebuffIcon]                                                                        = {
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

        PixelGlow                                                                       = {
            period                                                                      = 2,
            visible                                                                     = true
        }
    },

    -- Enlarge buff icon
    [EnlargeBuffIcon]                                                                   = {
        topLevel                                                                        = true,
    }
}


Style.UpdateSkin(SKIN_NAME, TEMPLATE_SKIN_STYLE)