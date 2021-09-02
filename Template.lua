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
__Sealed__() __ChildProperty__(AshUnitFrame, "AshBlzSkinSelectionHighlightTexture")
class "SelectionHighlightTexture" { Texture }

-- 仇恨指示器
__Sealed__() __ChildProperty__(AshUnitFrame, "AshBlzSkinAggroHighlight")
class "AggroHighlight" { Texture }

-- 载具
__Sealed__() __ChildProperty__(AshUnitFrame, "AshBlzSkinVehicleIcon")
class "VehicleIcon" { Texture }

-- 死亡
__Sealed__() __ChildProperty__(AshUnitFrame, "AshBlzSkinDeadIcon")
class "DeadIcon" { Texture }

-- Buff icon
__Sealed__() class "AshBlzSkinBuffIcon" { AshAuraPanelIcon }

-- Debuff icon
__Sealed__() class "AshBlzSkinDebuffIcon" { AshBlzSkinBuffIcon }

-- Debuff panel
__Sealed__() __ChildProperty__(AshUnitFrame, "AshBlzSkinDebuffPanel")
class "DebuffPanel"(function()
    inherit "AuraPanel"

    local shareCooldown         = { start = 0, duration = 0 }
    local priorityDebuffs       = {}
    local nonBossDebuffs        = {}

    local isPriorityDebuff
    local _, classFileName = UnitClass("player")
    if ( classFileName == "PALADIN" ) then
		isPriorityDebuff = function(spellID)
			local isForbearance = (spellId == 25771)
			return isForbearance or SpellIsPriorityAura(spellID)
		end
	else
		isPriorityDebuff = function(spellID)
			return SpellIsPriorityAura(spellID)
		end
	end

    local function shouldDisplayDebuff(unitCaster, spellID)
        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
        if ( hasCustom ) then
            return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") )
        else
            return true
        end
    end

    local function refreshAura(self, unit, filter, eleIdx, auraIdx, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, ...)
        if not name then return end

        if not self.CustomFilter or self.CustomFilter(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer, ...) then
            if not isBossDebuff then
                if isPriorityDebuff(spellID) then
                    tinsert(priorityDebuffs, auraIdx)
                elseif shouldDisplayDebuff(caster, spellID) then
                    tinsert(nonBossDebuffs, auraIdx)
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
                local name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, castByPlayer = UnitAura(unit, auraIdx, filter)

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
                
                if eleIdx > self.MaxCount then return eleIdx end
            end
        end
        return eleIdx
    end

    property "Refresh"          {
        set                     = function(self, unit)
            self.Unit           = unit
            wipe(priorityDebuffs)
            wipe(nonBossDebuffs)
            local filter = self.AuraFilter
            refreshAura(self, unit, filter, 1, 1, UnitAura(unit, 1, filter))

            local eleIdx = 1
            eleIdx = showElements(self, unit, filter, priorityDebuffs, eleIdx)
            eleIdx = showElements(self, unit, filter, nonBossDebuffs, eleIdx)
            self.Count = eleIdx -1
        end
    }

    -- 不允许更改.
    property "AuraFilter" { 
        type                    = struct{ AuraFilter } + String,
        field                   = "__AuraPanel_AuraFilter",
        set                     = Toolset.fakefunc,
        default                 = "HARMFUL"
    }
end)

-- 专用于BossDebuffPanel
class "AshBlzSkinBossDebuffIcon"(function()
    inherit "AshBlzSkinDebuffIcon"

    local function OnEnter(self)
        if self.ShowTooltip and self.AuraFilter then
            local parent        = self:GetParent()
            if not parent then return end

            GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
            GameTooltip:SetUnitAura(parent.Unit, self.AuraName, self.AuraFilter)
        end
    end

    function __ctor(self)
        super(self)
        self.OnEnter = OnEnter
    end

    property "AuraName" { type = String }
end)

-- BossDebuff
__Sealed__() __ChildProperty__(AshUnitFrame, "AshBlzSkinBossDebuffPanel")
class "BossDebuffPanel"(function()
    inherit "AuraPanel"

    local shareCooldown         = { start = 0, duration = 0 }
    local bossDebuffs           = {}
    local bossBuffs             = {}

    local function refreshAura(self, unit, filter, eleIdx, auraIdx, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        if not name then return end

        if not self.CustomFilter or self.CustomFilter(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...) then
            if isBossAura then
                if filter == "HARMFULE" then
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

                -- Harmful和Helpful混合了，auraIdx不对了，鼠标提示用auraName，具体看BossDebuffIcon
                -- self.AuraIndex[eleIdx]          = auraIdx
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

-- CastBar 修改自Scorpio.UI.CooldownStatusBar
__Sealed__() __ChildProperty__(AshUnitFrame, "AshBlzSkinCastBar")
class "CastBar" (function(_ENV)
    inherit "CooldownStatusBar"

    local function OnUpdate(self, elapsed)
        self.value = self.value + elapsed
        if self.value >= self.maxValue then
            self:Hide()
        else
            local value = self.Reverse and (self.maxValue - self.value) or self.value
            self:SetValue(value)
        end
    end

    function SetStatusBarTexture(self, texture)
        super.SetStatusBarTexture(self, texture)
        self.spark:SetPoint("CENTER", texture, "RIGHT", 0, 0)
    end

    function SetCooldown(self, start, duration)
        if duration <= 0 then
            self:Hide()
            return
        end
        self.maxValue  = duration
        self.value = start - GetTime()
        self:SetMinMaxValues(0, duration)
        self:Show()
    end

    __Template__{
        Spark           = Texture
    }
    function __ctor(self)
        self.value = 0
        self.maxValue = 0
        self.spark = self:GetChild("Spark")
        self.OnUpdate = self.OnUpdate + OnUpdate
    end
end)