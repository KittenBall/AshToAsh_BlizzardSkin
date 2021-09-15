Scorpio "AshToAsh.BlizzardSkin.Template" ""

import "Scorpio.Secure.UnitFrame"

UI.Property         {
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

-- 仇恨指示器
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinAggroHighlight")
class "AggroHighlight" { Texture }

-- 载具
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinVehicleIcon")
class "VehicleIcon" { Texture }

-- 死亡
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinDeadIcon")
class "DeadIcon" { Texture }

-- Buff icon
__Template__(AshAuraPanelIcon)
__Sealed__() class "AshBlzSkinBuffIcon"{
    Icon                = Texture
}

-- Debuff icon
__Sealed__() class "AshBlzSkinDebuffIcon" { AshBlzSkinBuffIcon }

-- ClassBuff icon
__Sealed__() class "AshBlzSkinClassBuffIcon" { AshBlzSkinBuffIcon }

-- 可驱散类型
__Sealed__() class "AshBlzSkinDispellIcon" { Scorpio.Secure.UnitFrame.AuraPanelIcon  }

-- 专用于BossDebuffPanel
class "AshBlzSkinBossDebuffIcon"(function()
    inherit "AshBlzSkinDebuffIcon"

    local function OnEnter(self)
        if self.ShowTooltip and self.AuraFilter then
            local parent        = self:GetParent()
            if not parent then return end

            GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
            GameTooltip:SetUnitAura(parent.Unit, self.AuraIndex, self.AuraFilter)
        end
    end

    function __ctor(self)
        super(self)
        self.OnEnter = OnEnter
    end

    property "AuraFilter" { type = String }

end)

-- Buff panel
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinBuffPanel")
class "BuffPanel"(function()
    inherit "AuraPanel"

    local shareCooldown         = { start = 0, duration = 0 }

    local function shouldDisplayBuff(unitCaster, spellId, canApplyAura)
        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT");
    
        if ( hasCustom ) then
            return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"));
        else
            return (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellId);
        end
    end

    local function refreshAura(self, unit, filter, eleIdx, auraIdx, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        if not name or eleIdx > self.MaxCount then return eleIdx end

        if not self.CustomFilter or self.CustomFilter(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...) then
            if shouldDisplayBuff(caster, spellID, canApplyAura) and not isBossAura then
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
                self.AuraSpellID[eleIdx]        = spellID
                self.AuraBossDebuff[eleIdx]     = isBossAura
                self.AuraCastByPlayer[eleIdx]   = castByPlayer

                eleIdx = eleIdx + 1
            end
        end
        
        auraIdx = auraIdx + 1
        return refreshAura(self, unit, filter, eleIdx, auraIdx, UnitAura(unit, auraIdx, filter))
    end

    property "Refresh"          {
        set                     = function(self, unit)
            self.Unit           = unit
            if not (unit  and self:IsVisible()) then return end
            local filter        = self.AuraFilter

            self.Count          = refreshAura(self, unit, filter, 1, 1, UnitAura(unit, 1, filter)) - 1
        end
    }

    property "AuraFilter"       {
        type                    = String,
        set                     = false,
        default                 = "HELPFUL"
    }
end)

-- BossDebuff Panel
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinBossDebuffPanel")
class "BossDebuffPanel"(function()
    inherit "AuraPanel"

    local shareCooldown         = { start = 0, duration = 0 }
    local bossDebuffs           = {}
    local bossBuffs             = {}

    local function refreshAura(self, unit, filter, eleIdx, auraIdx, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        if not name then return end

        if not self.CustomFilter or self.CustomFilter(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...) then
            if isBossAura then
                if filter == "HARMFUL" then
                    tinsert(bossDebuffs, auraIdx)
                elseif filter == "HELPFUL" then
                    tinsert(bossBuffs, auraIdx)
                end
            end
        end

        auraIdx                 = auraIdx + 1
        return refreshAura(self, unit, filter, eleIdx, auraIdx, UnitAura(unit, auraIdx, filter))
    end

    local function showElements(self, unit, filter, auras, eleIdx)
        if eleIdx > self.MaxCount then return eleIdx end

        for _, auraIdx in ipairs(auras) do
            if auraIdx then
                local name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer =  UnitAura(unit, auraIdx, filter)

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
                self.AuraSpellID[eleIdx]        = spellID
                self.AuraBossDebuff[eleIdx]     = isBossDebuff
                self.AuraCastByPlayer[eleIdx]   = castByPlayer
                self.AuraFilter[eleIdx]         = filter

                eleIdx = eleIdx + 1
                
                if eleIdx > self.MaxCount then return eleIdx end
            end
        end
        return eleIdx
    end

    property "Refresh"          {
        set                     = function(self, unit)
            self.Unit           = unit
            if not (unit  and self:IsVisible()) then return end
            wipe(bossDebuffs)
            wipe(bossBuffs)
            
            local filterHarmful = "HARMFUL"
            local filterHelpful = "HELPFUL"
            refreshAura(self, unit, filterHarmful, 1, 1, UnitAura(unit, 1, filterHarmful))
            refreshAura(self, unit, filterHelpful, 1, 1, UnitAura(unit, 1, filterHelpful))

            local eleIdx = 1
            eleIdx = showElements(self, unit, filterHarmful, bossDebuffs, eleIdx)
            eleIdx = showElements(self, unit, filterHelpful, bossBuffs, eleIdx)
            self.Count = eleIdx -1
        end
    }

    __Indexer__() __Observable__()
    property "AuraFilter" { set = Toolset.fakefunc }
end)

-- DispellDebuff Panel
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinDispellDebuffPanel")
class "DispellDebuffPanel" (function(_ENV)
    inherit "AuraPanel"

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
            self.AuraSpellID[eleIdx]        = spellID
            self.AuraBossDebuff[eleIdx]     = isBossDebuff
            self.AuraCastByPlayer[eleIdx]   = castByPlayer

            eleIdx = eleIdx + 1
        end
        
        auraIdx = auraIdx + 1
        return refreshAura(self, unit, filter, eleIdx, auraIdx, UnitAura(unit, auraIdx, filter))
    end

    property "Refresh"          {
        set                     = function(self, unit)
            self.Unit           = unit
            local filter        = self.AuraFilter
            if not (unit and filter and filter ~= "" and self:IsVisible()) then return end

            wipe(dispellDebuffs)
 
            self.Count          = refreshAura(self, unit, filter, 1, 1, UnitAura(unit, 1, filter)) - 1
        end
    }

    -- we don't care about priority in dispell panel
    property "AuraPriority"     { set = false }

    property "CustomFilter"     { set = false }

    property "AuraFilter"       {
        type                    = String,
        set                     = false,
        default                 = "HARMFUL"
    }
end)

local shareColor    = ColorType(0, 0, 0, 1)
TEMPLATE_SKIN_STYLE                                                                     = {

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

    -- 仇恨指示器
    [AggroHighlight]                                                                    = {
        drawLayer                                                                       = "ARTWORK",
        subLevel                                                                        = 3,
        file                                                                            = "Interface\\RaidFrame\\Raid-FrameHighlights",
        texCoords                                                                       = RectType(0.00781250, 0.55468750, 0.00781250, 0.27343750),
        setAllPoints                                                                    = true,
        visible                                                                         = Wow.UnitThreatLevel():Map("l=> l>0"),
        vertexColor                                                                     = Wow.UnitThreatLevel():Map(function(level)
            shareColor.r, shareColor.g, shareColor.b, shareColor.a = GetThreatStatusColor(level)
            return shareColor
        end)
    },

    -- 死亡图标
    [DeadIcon]                                                                          = {
        file                                                                            = "Interface\\EncounterJournal\\UI-EJ-Icons",
        texCoords                                                                       = RectType(0.375, 0.5, 0, 0.5),
        visible                                                                         = AshBlzSkinApi.UnitIsDead()
    },
}

Style.UpdateSkin(SKIN_NAME, TEMPLATE_SKIN_STYLE)