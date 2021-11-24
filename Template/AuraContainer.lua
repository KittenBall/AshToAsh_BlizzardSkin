Scorpio "AshToAsh.BlizzardSkin.Template.AuraContainer" ""

-------------------------------------------------
-- Buff filter
-------------------------------------------------

__Sealed__()
interface "IBuffFilter"(function()

    property "MaxPriority" {
        type                        = Number,
        default                     = 1
    }

    -- @return priority
    __Abstract__()
    function Filter(...) end

end)

__Sealed__()
class "BuffFilter"(function()
    extend "IBuffFilter"
    
    function ShouldDisplayBuff(self, unitCaster, spellId, canApplyAura)
        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
        
        if ( hasCustom ) then
            return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"))
        else
            return (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellId)
        end
    end
    
    function Filter(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        return (ShouldDisplayBuff(self, caster, spellID, canApplyAura) and not isBossAura) and 1 or nil
    end

end)

__Sealed__()
class "BuffFilterClassic"(function()
    extend "IBuffFilter"


end)

-------------------------------------------------
-- Auras
-------------------------------------------------

-- Aura data
__Sealed__() struct "AuraData" {
    { name = "Unit"             },
    { name = "Index"            },
    { name = "Name"             },
    { name = "Icon"             },
    { name = "Count"            },
    { name = "DebuffType"       },
    { name = "Stealeable"       },
    { name = "Caster"           },
    { name = "SpellID"          },
    { name = "IsBossAura"       },
    { name = "CasterByPlayer"   },
    { name = "Filter"           },
    { name = "Duration"         },
    { name = "ExpirationTime"   },
    { name = "Priority"         }
}

-- Base aura icon
__Sealed__()
class "BaseAuraIcon"(function()
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

    __Abstract__()
    function SetAuraData(self, data)
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

    function __ctor(self)
        self.OnEnter            = self.OnEnter + OnEnter
        self.OnLeave            = self.OnLeave + OnLeave
        self.OnUpdate           = self.OnUpdate + OnUpdate
    end

end)

-- Aura icon
__Sealed__()
class "AuraIcon"(function()
    inherit "BaseAuraIcon"

    function SetAuraData(self, data)
        self.AuraIndex = data.Index
        self.AuraFilter = data.Filter
        self.AuraCaster = data.Caster
        self:SetLabel(data.Count)
        self:GetChild("Icon"):SetTexture(data.Icon)
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

    __Template__{
        Cooldown    = OmniCCCooldown,
        Icon        = Texture,
        Label       = FontString
    }
    function __ctor(self)
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

-- Dispel debuff icon
class "DispelDebuffIcon"(function()
    inherit "BaseAuraIcon"

    function SetAuraData(self, data)
        self.AuraIndex = data.Index
        self.AuraFilter = data.Filter
        self.AuraCaster = data.Caster
        if data.DebuffType then
            self:GetChild("Icon"):SetTexture("Interface\\RaidFrame\\Raid-Icon-Debuff" .. data.DebuffType)
        end
    end

    __Template__{
        Icon        = Texture
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
    inherit "Frame"

    local auraDataPool              = Recycle()
    local buffCache                 = {}

    -------------------------------------------------
    -- Functions
    -------------------------------------------------

    local function wipeCache(cache)
        for _, auraData in ipairs(cache) do
            auraDataPool(auraData)
        end
        wipe(cache)
    end

    local function wipeCaches()
        wipeCache(buffCache)
    end

    local function cacheAuraData(cache, priority, unit, index, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
        local auraData              = auraDataPool()
        auraData.Priority           = priority
        auraData.Unit               = unit
        auraData.Index              = index
        auraData.Name               = name
        auraData.Icon               = icon
        auraData.Count              = count
        auraData.DebuffType         = dtype
        auraData.Duration           = duration
        auraData.ExpirationTime     = expires
        auraData.Caster             = caster
        auraData.SpellID            = spellID
        auraData.IsBossAura         = isBossAura
        auraData.CasterByPlayer     = castByPlayer
        auraData.Stealeable         = isStealable and not UnitIsUnit(unit, "player")

        tinsert(cache, auraData)
    end

    function Refresh(self, unit)
        if not (unit and self:IsVisible()) then return self:HideAllAuras() end

        wipeCaches()

        local index, maxPriorityAuraCount = 1, 0
        local auraFilter, maxPriority, filter, maxAuraCount

        -- Buff filter
        auraFilter, maxPriority, filter, maxAuraCount = "HELPFUL", self.BuffFilter.MaxPriority, self.BuffFilter, self.BuffCount
        while true do
            local name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer = UnitAura(unit, index, auraFilter)
            if not name then break end

            local priority = filter(unit, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
            if priority then
                cacheAuraData(buffCache, priority, unit, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                
                -- just check max priority aura count to reduce loop
                if priority == maxPriority then
                    maxPriorityAuraCount = maxPriorityAuraCount + 1
                    if maxPriorityAuraCount >= maxAuraCount then
                        break
                    end
                end
            end

            index = index + 1
        end
        self:ShowBuffs()
    end

    local function compareAuraData(a, b)
        return a.Priority > b.Priority
    end

    function ShowBuffs(self)
        sort(buffCache, compareAuraData)

        for i = 1, self.BuffCount do
            local icon = self.BuffIcons[i]
            if not icon then
                icon = BuffIcon("BuffIcon" .. i, self)
                if i == 1 then
                    icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -3, 0)
                else
                    icon:SetPoint("RIGHT", self:GetChild("BuffIcon" .. (i-1)), "LEFT", -1, 0)
                end

                self.BuffIcons[i] = icon
            end
            icon:SetAuraData(buffCache[i])
        end
    end

    function HideAllAuras(self)
        self:HideAuras(self.BuffIcons)
        self:HideAuras(self.DebuffIcons)
        self:HideAuras(self.EnlargeDebuffIcons)
        self:HideAuras(self.EnlargeBuffIcons)
        self:HideAuras(self.ClassBuffIcons)
        self:HideAuras(self.DispelDebuffIcons)
        self:HideAuras(self.BossDebuffIcons)
    end

    function HideAuras(self, auras)
        for i = 1, #auras do
            auras[i]:Hide()
        end
    end

    function ResizeAuras(self, auras, width, height)
        for i = 1, #auras do
            auras[i]:SetSize(width, height)
        end
    end

    -------------------------------------------------
    -- Propertys
    -------------------------------------------------

    property "BuffCount"            {
        type                        = NaturalNumber,
        default                     = 3,
        handler                     = function(self)
            self:HideAuras(self.BuffIcons)
        end
    }

    property "DebuffCount"          {
        type                        = NaturalNumber,
        default                     = 3,
        handler                     = function(self)
            self:HideAuras(self.DebuffIcons)
        end
    }

    property "BossDebuffCount"      {
        type                        = NaturalNumber,
        default                     = 1,
        set                         = Toolset.fakefunc
    }

    property "EnlargeDebuffCount"   {
        type                        = NaturalNumber,
        default                     = 2,
        handler                     = function(self)
            self:HideAuras(self.EnlargeDebuffIcons)
        end
    }

    property "EnlargeBuffCount"     {
        type                        = NaturalNumber,
        default                     = 2,
        handler                     = function(self)
            self:HideAuras(self.EnlargeBuffIcons)
        end
    }

    property "DispelDebuffCount"    {
        type                        = NaturlNumber,
        default                     = 4,
        handler                     = function(self)
            self:HideAuras(self.DispelDebuffIcons)
        end
    }

    property "ClassBuffCount"       {
        type                        = NaturlNumber,
        default                     = 1,
        handler                     = function(self)
            self:HideAuras(self.ClassBuffIcons)
        end
    }

    property "BuffFilter"           {
        default                     = Scorpio.IsRetal and BuffFilter(),
        set                         = Toolset.fakefunc
    }

    property "Refresh"              {
        set                         = "Refresh"
    }

    function __ctor(self)
        self.BuffIcons              = {}
        self.DebuffIcons            = {}
        self.EnlargeDebuffIcons     = {}
        self.EnlargeBuffIcons       = {}
        self.ClassBuffIcons         = {}
        self.DispelDebuffIcons      = {}
        self.BossDebuffIcons        = {}
    end

end)

TEMPLATE_SKIN_STYLE                                                                     = {
    [BaseAuraIcon]                                                                      = {
        enableMouse                                                                     = AshBlzSkinApi.AuraTooltipEnable(),
    },

    [AuraIcon]                                                                          = {
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
    },

    -- Dispel debuff icon
    [DispelDebuffIcon]                                                                  = {
        Icon                                                                            = {
            drawLayer                                                                   = "ARTWORK",
            setAllPoints                                                                = true,
            texCoords                                                                   = RectType(0.125, 0.875, 0.125, 0.875)
        }
    }
}


Style.UpdateSkin(SKIN_NAME, TEMPLATE_SKIN_STYLE)