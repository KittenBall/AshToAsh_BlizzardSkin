Scorpio "AshToAsh.BlizzardSkin.Template.AuraContainer" ""


__Sealed__()
interface "AuraFilter"(function()

    property "MaxPriority"          {
        type                        = Number,
        default                     = 1
    }

    property "Data"                 {
        type                        = RawTable,
        default                     = {}
    }

    property "SpecID"               {
        type                        = Number,
        default                     = 0
    }

    property "Class"                {
        type                        = String,
        default                     = UnitClassBase("player")
    }

    __Abstract__()
    function Filter(...) end

    __Abstract__()
    function SortDisplayOrder(...) end

end)

-------------------------------------------------
-- Buff filter
-------------------------------------------------

--@retail@
__Sealed__()
class "BuffFilter"(function()
    extend "AuraFilter"
    
    function ShouldDisplayBuff(self, unitCaster, spellId, canApplyAura)
        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
        
        if ( hasCustom ) then
            return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"))
        else
            return (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellId)
        end
    end
    
    function Filter(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        return (not isBossAura and self:ShouldDisplayBuff(caster, spellID, canApplyAura)) and self.MaxPriority or nil
    end

end)
--@end-retail@

--[===[@non-version-retail@
__Sealed__()
class "BuffFilter"(function()
    extend "AuraFilter"

    -- 同一个职业会互相顶的Buff
    local classBuffList         = {
        PALADIN                 = {
            -- 强效王者祝福
            [25898]             = true,
            -- 王者祝福
            [20217]             = true,
            -- 强效庇护祝福
            [27169]             = true,
            -- 庇护祝福
            [27168]             = true,
            -- 强效力量祝福
            [27141]             = true,
            -- 力量祝福
            [27140]             = true,
            -- 强效智慧祝福
            [27143]             = true,
            -- 智慧祝福
            [27142]             = true,
            -- 强效光明祝福
            [27145]             = true,
            -- 光明祝福
            [27144]             = true,
            -- 强效拯救祝福
            [25895]             = true,
            -- 拯救祝福
            [1038]              = true
        },

        MAGE                    = {
            -- 奥术智慧
            [27126]             = true,
            -- 奥术光辉
            [27127]             = true
        },

        DRUID                   = {
            -- 野性赐福
            [26991]             = true,
            -- 野性印记
            [26990]             = true
        },

        PRIEST                  = {
            -- 坚韧祷言
            [25392]             = true,
            -- 真言术：韧
            [25389]             = true,
            -- 精神祷言
            [32999]             = true,
            -- 神圣之灵
            [25312]             = true,
            -- 暗影防护祷言
            [39374]             = true,
            -- 防护暗影
            [25433]             = true
        },

        SHAMAN                  = {
            -- 大地之盾
            [32594]             = true
        }
    }

    local classBuffPriority     = 0

    local function shouldShowClassBuff(self, spellId)
        local buffs = classBuffList[self.Class]
        return buffs and buffs[spellId]
    end

    function ShouldDisplayBuff(self, unitCaster, spellId, canApplyAura)
        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
        
        if ( hasCustom ) then
            return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"))
        else
            return (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellId)
        end
    end
    
    function Filter(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        if not isBossAura then
            if self:ShouldDisplayBuff(caster, spellID, canApplyAura) then
                if shouldShowClassBuff(self, spellID) then
                    return classBuffPriority
                else
                    return self.MaxPriority
                end
            end
        end
    end

    -- 如果职业buff会被显示的话，将职业buff添加到所有buff的最前面
    function SortDisplayOrder(self, src, maxCount)
        local count = #src
        if count > 1 and count <= maxCount then
            for i = 2, count do
                local aura = src[i]
                if aura.priority == classBuffPriority then
                    tremove(src, i)
                    tinsert(src, 1)
                end
            end
        end
    end

end)
--@end-non-version-retail@]===]

-------------------------------------------------
-- Debuff filter
-------------------------------------------------

--@retail@
__Sealed__()
class "DebuffFilter"(function()
    extend "AuraFilter"

    property "MaxPriority" {
        type                        = Integer,
        default                     = 255
    }

    local isPriorityDebuff
    local classFileName = UnitClassBase("player")
    if classFileName == "PALADIN" then
		isPriorityDebuff = function(spellID)
			local isForbearance = (spellId == 25771)
			return isForbearance or SpellIsPriorityAura(spellID)
		end
	else
		isPriorityDebuff = function(spellID)
			return SpellIsPriorityAura(spellID)
		end
	end

    function ShouldDisplayDebuff(self, unitCaster, spellID)
        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
        if ( hasCustom ) then
            return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") )
        else
            return true
        end
    end

    function Filter(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        if not isBossAura then
            if isPriorityDebuff(spellID) then return self.MaxPriority end
            if self:ShouldDisplayDebuff(caster, spellID) then return 1 end
        end
    end

    function FilterPriorityAura(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        return not isBossAura and isPriorityDebuff(spellID) and self.MaxPriority or nil
    end

    function FilterRaidAura(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        return not isBossAura and not isPriorityDebuff(spellID) and self:ShouldDisplayDebuff(caster, spellID) and 1 or nil
    end

end)
--@end-retail@

--[===[@non-version-retail@
__Sealed__()
class "DebuffFilter"(function()

    property "MaxPriority" {
        type                        = Integer,
        default                     = 255
    }

    local isPriorityDebuff
    local classFileName = UnitClassBase("player")
    if ( classFileName == "PALADIN" ) then
		isPriorityDebuff = function(spellID)
			return spellID == 25771
		end
	elseif (classFileName == "PRIEST") then
		isPriorityDebuff = function(spellID)
            return spellID == 6788
		end
    else
        isPriorityDebuff = function()
            return false
        end
	end

    function ShouldDisplayDebuff(self, unitCaster, spellID)
        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
        if ( hasCustom ) then
            return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") )
        else
            return true
        end
    end

    function Filter(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        if not isBossAura then
            if isPriorityDebuff(spellID) then return self.MaxPriority end
            if self:ShouldDisplayDebuff(caster, spellID) then return 1 end
        end
    end

    function FilterPriorityAura(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        return not isBossAura and isPriorityDebuff(spellID) and self.MaxPriority or nil
    end

    function FilterRaidAura(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        return not isBossAura and not isPriorityDebuff(spellID) and self:ShouldDisplayDebuff(caster, spellID) and 1 or nil
    end

end)
--@end-non-version-retail@]===]

-------------------------------------------------
-- Class buff filter
-------------------------------------------------

__Sealed__()
class "ClassBuffFilter"(function()
    extend "AuraFilter"

    function Filter(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        local aura = self.Data[spellID]
        if aura then
            return type(aura) == "table" and aura.Priority or self.MaxPriority
        end
    end

end)

-------------------------------------------------
-- Dispel debuff filter
-------------------------------------------------

--@retail@
__Sealed__()
class "DispelDebuffFilter"(function()
    extend "AuraFilter"

    local classDispelType           = {
        -- 奶骑
        [65]                        = {
            Magic                   = true,
            Disease                 = true,
            Poison                  = true
        },
        -- 防骑
        [66]                        = {
            Disease                 = true,
            Poison                  = true
        },
        -- 惩戒
        [70]                        = {
            Disease                 = true,
            Poison                  = true
        },
        -- 奶萨
        [264]                       = {
            Magic                   = true,
            Curse                   = true
        },
        --增强
        [263]                       = {
            Curse                   = true
        },
        -- 元素
        [262]                       = {
            Curse                   = true
        },
        -- 戒律
        [256]                       = {
            Magic                   = true,
            Disease                 = true
        },
        -- 神牧
        [257]                       = {
            Magic                   = true,
            Disease                 = true
        },
        -- 暗牧
        [258]                       = {
            Magic                   = true,
            Disease                 = true
        },
        -- 奶僧
        [270]                       = {
            Magic                   = true,
            Disease                 = true,
            Poison                  = true
        },
        -- 踏风
        [269]                       = {
            Disease                 = true,
            Poison                  = true
        },
        -- 酒仙
        [268]                       = {
            Disease                 = true,
            Poison                  = true
        },
        -- 火法
        [63]                        = {
            Curse                   = true
        },
        -- 冰法
        [64]                        = {
            Curse                   = true
        },
        -- 奥法
        [62]                        = {
            Curse                   = true
        },
        -- 鸟德 
        [102]                       = {
            Curse                   = true,
            Poison                  = true
        },
        -- 野德
        [103]                       = {
            Curse                   = true,
            Poison                  = true
        },
        -- 熊
        [104]                       = {
            Curse                   = true,
            Poison                  = true
        },
        -- 奶德
        [105]                       = {
            Magic                   = true,
            Curse                   = true,
            Poison                  = true
        }
    }

    function Filter(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        return classDispelType[self.SpecID] and classDispelType[self.SpecID][dtype]
    end

end)
--@end-retail@

--[===[@non-version-retail@
__Sealed__()
class "DispelDebuffFilter"(function()
    extend "AuraFilter"

    local classDispelType           = {
        PALADIN                     = {
            Magic                   = true,
            Disease                 = true,
            Poison                  = true
        },
        SHAMAN                      = {
            Disease                 = true,
            Poison                  = true
        },
        DRUID                       = {
            Curse                   = true,
            Poison                  = true
        },
        PRIEST                      = {
            Magic                   = true,
            Disease                 = true
        },
        MAGE                        = {
            Curse                   = true
        }
    }

    function Filter(self, unit, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer, ...)
        return classDispelType[self.Class] and classDispelType[self.Class][dtype]
    end

end)
--@end-non-version-retail@]===]

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

    function SetAuraData(self, data)
        self.AuraIndex  = data.Index
        self.AuraFilter = data.Filter
        self.AuraCaster = data.Caster
        self.Unit       = data.Unit
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

    property "Unit"             { type = String }

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
        super.SetAuraData(self, data)
        self:SetLabel(data.Count)
        self:GetChild("Icon"):SetTexture(data.Icon)
        self:GetChild("Cooldown"):SetCooldown(data.ExpirationTime - data.Duration, data.Duration)
    end

    function SetLabel(self, auraCount)
        local label = auraCount
        if auraCount >= 100 then
            label = BUFF_STACKS_OVERFLOW
        elseif auraCount <= 1 then
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

    function SetAuraData(self, data)
        super.SetAuraData(self, data)
        if UnitExists(data.Caster) and UnitIsUnit("player", data.Caster) then
            self:SetAlpha(1)
        else
            self:SetAlpha(0.5)
        end
    end

    function __ctor(self)
        super(self)
    end

end)

-- Debuff icon
class "DebuffIcon"(function()
    inherit "AuraIcon"

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
        self.Unit = data.Unit
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
class "BossAuraIcon" { DebuffIcon }

-- Class buff icon
class "ClassBuffIcon" { AuraIcon }

-- Enlarge buff icon
class "EnlargeBuffIcon" { AuraIcon }

-- Enlarge Debuff icon
class "EnlargeDebuffIcon" { DebuffIcon }

__ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinAuraContainer")
__Sealed__()
class "AuraContainer"(function()
    inherit "Frame"

    -- 可驱散Debuff类型
    local dispelDebuffTypes         = { Magic = true, Curse = true, Disease = true, Poison = true }
    local dispelDebuffColor         = {}
    local buffFilter                = BuffFilter()
    local debuffFilter              = DebuffFilter()
    local classBuffFilter           = ClassBuffFilter()
    local dispelDebuffFilter        = DispelDebuffFilter()

    local auraDataPool              = Recycle()
    local buffCache                 = {}
    local debuffCache               = {}
    local bossAuraCache             = {}
    local dispelDebuffs             = {}
    local dispelDebuffCache         = {}
    local classBuffCache            = {}
    local canDispelType             = nil

    local bossBuffPriority          = 1
    local bossDebuffPriority        = 2

    -------------------------------------------------
    -- Functions
    -------------------------------------------------

    -- Increase debuff color's lightness
    local function getDispellDebuffColor(dType)
        local color = dispelDebuffColor[dType]
        if not color then
            local r, g, b = DebuffTypeColor[dType]
            local h, s, l = Color(r, g, b):ToHSL()
            color = Color.FromHSL(h, s, l * 1.3)
            dispelDebuffColor[dType] = color
        end
    
        return color
    end

    local function wipeCache(cache)
        for _, auraData in ipairs(cache) do
            auraDataPool(auraData)
        end
        wipe(cache)
    end

    local function wipeCaches()
        wipeCache(buffCache)
        wipeCache(debuffCache)
        wipeCache(bossAuraCache)
        wipe(dispelDebuffs)
        wipeCache(dispelDebuffCache)
        wipeCache(classBuffCache)
        canDispelType = nil
    end

    local function cacheAuraData(cache, priority, unit, index, filter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
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
        auraData.Filter             = filter
        auraData.Stealeable         = isStealable and not UnitIsUnit(unit, "player")

        tinsert(cache, auraData)
    end

    local function compareAuraData(a, b)
        return a.Priority > b.Priority
    end

    --@retail@
    local foreachAura = AuraUtil.ForEachAura
    --@end-retail@
    
    --[===[@non-version-retail@
    local foreachAura = function(unit, filter, maxCount, func)
        if maxCount and maxCount <= 0 then
            return
        end
        local index = 1
        while true do
            if func(UnitAura(unit, index, filter)) then break end
            index = index + 1
        end
    end
    --@end-non-version-retail@]===]

    function Refresh(self, unit)
        if not (unit and self:IsVisible()) then return self:HideAllAuras() end

        wipeCaches()

        local index = 1
        local auraFilter
        local displayOnlyDispellableDebuffs = self.DisplayOnlyDispellableDebuffs
        local blackAuraList = self.BlackAuraList

        --  Harmful
        auraFilter = "HARMFUL"
        local maxDebuffPriority, maxDebuffCount, debuffCount = debuffFilter.MaxPriority, self.DebuffCount, 0
        local maxBossDebuffCount, bossDebuffCount = self.BossAuraCount, 0
        foreachAura(unit, auraFilter, math.max(maxDebuffCount, maxBossDebuffCount), function(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
            -- compat classic
            if not name then return true end

            if blackAuraList[spellID] then return true end

            if not displayOnlyDispellableDebuffs and debuffCount < maxDebuffCount then
                -- Debuff filter
                local priority = debuffFilter:Filter(unit, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                if priority then
                    cacheAuraData(debuffCache, priority, unit, index, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)

                    -- just check max priority aura count to reduce loop
                    if priority == maxDebuffPriority then
                        debuffCount = debuffCount + 1
                    end
                end
            elseif debuffCount < maxDebuffCount then
                -- Priority debuff
                local priority = debuffFilter:FilterPriorityAura(unit, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                if priority then
                    cacheAuraData(debuffCache, priority, unit, index, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)

                    -- just check max priority aura count to reduce loop
                    if priority == maxDebuffPriority then
                        debuffCount = debuffCount + 1
                    end
                end
            end
            
            -- Boss debuff filter
            if isBossAura and bossDebuffCount < maxBossDebuffCount then
                cacheAuraData(bossAuraCache, bossDebuffPriority, unit, index, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                bossDebuffCount = bossDebuffCount + 1
            end

            index = index + 1
            
            return not (debuffCount < maxDebuffCount or bossDebuffCount < maxBossDebuffCount)
        end)

        -- Harmful|Raid
        auraFilter, index = "HARMFUL|RAID", 1
        local maxDispelCount, dispelCount = self.DispelDebuffCount, 0
        local checkDispelAbility = self.CheckDispelAbilityEnable
        foreachAura(unit, auraFilter, math.max(maxDispelCount, debuffCount), function(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
            -- compat classic
            if not name then return true end

            if blackAuraList[spellID] then return true end

            if displayOnlyDispellableDebuffs and debuffCount < maxDebuffCount then
                -- Debuff filter
                local priority = debuffFilter:FilterRaidAura(unit, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                if priority then
                    cacheAuraData(debuffCache, priority, unit, index, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)

                    -- just check max priority aura count to reduce loop
                    if priority == maxDebuffPriority then
                        debuffCount = debuffCount + 1
                    end
                end
            end

            -- Dispel debuff filter
            if dispelDebuffTypes[dtype] and not dispelDebuffs[dtype] then
                cacheAuraData(dispelDebuffCache, 0, unit, index, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                dispelDebuffs[dtype] = true
                dispelCount = dispelCount + 1
            end

            -- Dispel ability filter
            if (checkDispelAbility and not canDispelType) then
                local canDispel = dispelDebuffFilter:Filter(unit, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                if canDispel then
                    canDispelType = dtype
                end
            end

            index = index + 1

            return not (dispelCount < maxDispelCount or (displayOnlyDispellableDebuffs and debuffCount < maxDebuffCount) or (checkDispelAbility and not canDispelType))
        end)

        -- Helpful
        auraFilter, index = "HELPFUL", 1
        local maxBuffPriority, maxBuffCount, buffCount = buffFilter.MaxPriority, self.BuffCount, 0
        local maxBossBuffCount, bossBuffCount = self.BossAuraCount, 0
        local maxClassBuffPriority, maxClassBuffCount, classBuffCount = classBuffFilter.MaxPriority, self.ClassBuffCount, 0
        foreachAura(unit, auraFilter, math.max(maxClassBuffCount, maxBuffCount, maxBossBuffCount), function(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
            -- compat classic
            if not name then return true end

            if blackAuraList[spellID] then return true end

            local filtered = false
            
            if classBuffCount < maxClassBuffCount then
                -- Class buff filter
                local priority = classBuffFilter:Filter(unit, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                if priority then
                    filtered = true
                    cacheAuraData(classBuffCache, priority, unit, index, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                    -- just check max priority aura count to reduce loop
                    if priority == maxClassBuffPriority then
                        classBuffCount = classBuffCount + 1
                    end
                end
            end

            -- Boss buff filter
            if not filtered and isBossAura and bossBuffCount < maxBossBuffCount then
                filtered = true
                cacheAuraData(bossAuraCache, bossBuffPriority, unit, index, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                bossBuffCount = bossBuffCount + 1
            end

            if not filtered and buffCount < maxBuffCount then
                -- Buff filter
                local priority = buffFilter:Filter(unit, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                if priority then
                    filtered = true
                    cacheAuraData(buffCache, priority, unit, index, auraFilter, name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossAura, castByPlayer)
                    -- just check max priority aura count to reduce loop
                    if priority == maxBuffPriority then
                        buffCount = buffCount + 1
                    end
                end
            end

            index = index + 1

            return not (buffCount < maxBuffCount or bossBuffCount < maxBossBuffCount)
        end)

        -- sort auras
        sort(buffCache, compareAuraData)
        buffFilter:SortDisplayOrder(buffCache, maxBuffCount)
        sort(bossAuraCache, compareAuraData)
        sort(debuffCache, compareAuraData)
        sort(classBuffCache, compareAuraData)
        
        -- Show auras
        self:ShowBuffs()
        self:ShowBossAuras()
        self:ShowDebuffs()
        self:ShowDispelDebuffs()
        self:ShowClassBuffs()
        self:ShowDispelAbiility()
    end

    local function getScaleSize(self, value)
        local componentScale = min(self:GetWidth() / 72, self:GetHeight() / 36)
        return (value or 10) * componentScale
    end

    function ShowBuffs(self)
        local size = #buffCache
        for i = 1, self.BuffCount do
            local icon = self.BuffIcons[i]
            if not icon and i <= size then
                icon = BuffIcon("BuffIcon" .. i, self)
                local auraSize = getScaleSize(self, self.BuffSize)
                icon:SetSize(auraSize, auraSize)
                if i == 1 then
                    icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.PaddingRight, self.PaddingBottom)
                else
                    icon:SetPoint("RIGHT", self:GetChild("BuffIcon" .. (i-1)), "LEFT", -1, 0)
                end

                self.BuffIcons[i] = icon
            end

            if icon then
                icon.AuraData = buffCache[i]
            end
        end
    end

    function ShowBossAuras(self)
        local size = #bossAuraCache
        for i = 1, self.BossAuraCount do
            local icon = self.BossAuraIcons[i]
            if not icon and i <= size then
                icon = BossAuraIcon("BossAuraIcon" .. i, self)
                local auraSize = getScaleSize(self, self.BossAuraSize)
                icon:SetSize(auraSize, auraSize)
                if i == 1 then
                    icon:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.PaddingLeft, self.PaddingBottom)
                else
                    icon:SetPoint("LEFT", self:GetChild("BossAuraIcon" .. (i-1)), "RIGHT", 1.5, 0)
                end

                self.BossAuraIcons[i] = icon
            end

            if icon then
                icon.AuraData = bossAuraCache[i]
            end
        end

        self.__DisplayBossAuraCount = math.min(size, self.BossAuraCount)
    end

    function ShowDebuffs(self)
        local size = #debuffCache
        local debuffCount = (self.__DisplayBossAuraCount > 0) and self.DebuffCountWhenBossAura or self.DebuffCount
        for i = 1, debuffCount do
            local icon = self.DebuffIcons[i]
            if not icon and i <= size then
                icon = DebuffIcon("DebuffIcon" .. i, self)
                local auraSize = getScaleSize(self, self.DebuffSize)
                icon:SetSize(auraSize, auraSize)
                if i ~= 1 then
                    icon:SetPoint("LEFT", self:GetChild("DebuffIcon" .. (i-1)), "RIGHT", 1.5, 0)
                end

                self.DebuffIcons[i] = icon
            end

            if icon then
                if i == 1 then
                    icon:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.PaddingLeft + self.__DisplayBossAuraCount * (self.BossAuraSize + 1.5), self.PaddingBottom)
                end

                icon.AuraData = debuffCache[i]
            end
        end
    end

    function ShowDispelDebuffs(self)
        local size = #dispelDebuffCache
        for i = 1, self.DispelDebuffCount do
            local icon = self.DispelDebuffIcons[i]
            if not icon and i <= size then
                icon = DispelDebuffIcon("DispelDebuffIcon" .. i, self)
                local auraSize = getScaleSize(self, self.DispelDebuffSize)
                icon:SetSize(auraSize, auraSize)
                if i == 1 then
                    icon:SetPoint("TOPRIGHT", self, "TOPRIGHT", -self.PaddingRight, -self.PaddingTop)
                else
                    icon:SetPoint("RIGHT", self:GetChild("DispelDebuffIcon" .. (i-1)), "LEFT", -1, 0)
                end

                self.DispelDebuffIcons[i] = icon
            end

            if icon then
                icon.AuraData = dispelDebuffCache[i]
            end
        end
    end

    function ShowClassBuffs(self)
        local size = #classBuffCache
        local count = self.ClassBuffCount
        local auraSize = getScaleSize(self, self.ClassBuffSize)
        local margin = 1
        for i = 1, count do
            local icon = self.ClassBuffIcons[i]
            if not icon and i <= size then
                icon = ClassBuffIcon("ClassBuffIcon" .. i, self)
                icon:SetSize(auraSize, auraSize)
                if i ~= 1 then
                    icon:SetPoint("LEFT", self:GetChild("ClassBuffIcon" .. (i-1)), "RIGHT", margin, 0)
                end

                self.ClassBuffIcons[i] = icon
            end

            if icon then
                if i == 1 then
                    icon:SetPoint("LEFT", self, "CENTER", -(((auraSize + margin) * size - margin)/2), 0)
                end
                icon.AuraData = classBuffCache[i]
            end
        end
    end

    function ShowDispelAbiility(self)
        local glow = self:GetChild("PixelGlow")
        if canDispelType then
            glow.Color = getDispellDebuffColor(canDispelType)
            glow:Show()
        else
            glow:Hide()
        end
    end

    function HideAllAuras(self)
        self:HideAuras(self.BuffIcons)
        self:HideAuras(self.DebuffIcons)
        self:HideAuras(self.ClassBuffIcons)
        self:HideAuras(self.DispelDebuffIcons)
        self:HideAuras(self.BossAuraIcons)
    end

    function HideAuras(self, auras, newCount, oldCount)
        if newCount and oldCount then
            if newCount < oldCount then
                for i = newCount + 1, oldCount do
                    if auras[i] then auras[i]:Hide() end
                end
            end
        else
            for i = 1, #auras do
                if auras[i] then auras[i]:Hide() end
            end
        end
    end

    function ResizeAllAuras(self)
        self:ResizeAuras(self.BuffIcons, self.BuffSize)
        self:ResizeAuras(self.DebuffIcons)
        self:ResizeAuras(self.ClassBuffIcons)
        self:ResizeAuras(self.DispelDebuffIcons)
        self:ResizeAuras(self.BossAuraIcons)
    end

    function ResizeAuras(self, auras, size)
        size = getScaleSize(self, size)
        for i = 1, #auras do
            if auras[i] then
                auras[i]:SetSize(size, size)
            end
        end
    end

    function OnPaddingChanged(self, paddingLeft, paddingTop, paddingRight, paddingBottom)
        if paddingTop or paddingRight then
            local icon = self.DispelDebuffIcons[1]
            if icon then
                icon:SetPoint("TOPRIGHT", self, "TOPRIGHT", -self.PaddingRight, -self.PaddingTop)
            end
        end

        if paddingLeft or paddingBottom then
            local icon = self.BossAuraIcons[1]
            if icon then
                icon:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.PaddingLeft, self.PaddingBottom)
            end
        end

        if paddingRight or paddingBottom then
            local icon = self.BuffIcons[1]
            if icon then
                icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.PaddingRight, self.PaddingBottom)
            end
        end
    end

    local function OnSizeChanged(self, width, height)
        self:ResizeAllAuras()
    end

    -------------------------------------------------
    -- Propertys
    -------------------------------------------------

    -------------------------------------------------
    --                  Buff                       --
    -------------------------------------------------

    property "BuffCount"            {
        type                        = NaturalNumber,
        default                     = 3,
        handler                     = function(self, new, old)
            self:HideAuras(self.BuffIcons, new, old)
        end
    }

    property "BuffSize"             {
        type                        = Number,
        default                     = 1,
        handler                     = function(self, size)
            self:ResizeAuras(self.BuffIcons, size)
        end
    }

    -------------------------------------------------
    --                 Debuff                      --
    -------------------------------------------------

    property "DebuffCount"          {
        type                        = NaturalNumber,
        default                     = 3,
        handler                     = function(self, new, old)
            self:HideAuras(self.DebuffIcons, new, old)
        end
    }

    property "DebuffCountWhenBossAura" {
        type                        = NaturalNumber,
        default                     = 1,
        handler                     = function(self, new, old)
            self:HideAuras(self.DebuffIcons, new, old)
        end
    }

    property "DebuffSize"           {
        type                        = Number,
        default                     = 1,
        handler                     = function(self, size)
            self:ResizeAuras(self.DebuffIcons, size)
        end
    }

    property "DisplayOnlyDispellableDebuffs" {
        type                        = Boolean,
        default                     = false
    }

    -------------------------------------------------
    --             Boss Aura                       --
    -------------------------------------------------

    property "BossAuraCount"        {
        type                        = NaturalNumber,
        default                     = 1,
        set                         = Toolset.fakefunc
    }

    property "BossAuraSize"         {
        type                        = Number,
        default                     = 1,
        handler                     = function(self, size)
            self:ResizeAuras(self.BossAuraIcons, size)
        end
    }

    -------------------------------------------------
    --            Dispel debuff                    --
    -------------------------------------------------

    property "DispelDebuffCount"    {
        type                        = NaturlNumber,
        default                     = 4,
        set                         = Toolset.fakefunc
    }

    property "DispelDebuffSize"     {
        type                        = Number,
        default                     = 1,
        handler                     = function(self, size)
            self:ResizeAuras(self.DispelDebuffIcons, size)
        end
    }

    -------------------------------------------------
    --            Class buff                       --
    -------------------------------------------------

    property "ClassBuffCount"       {
        type                        = NaturlNumber,
        default                     = 2,
        handler                     = function(self, new, old)
            self:HideAuras(self.ClassBuffIcons, new, old)
        end
    }

    property "ClassBuffSize"        {
        type                        = Number,
        default                     = 1,
        handler                     = function(self, size)
            self:ResizeAuras(self.ClassBuffIcons, size)
        end
    }

    property "ClassBuffFilterData"  {
        type                        = RawTable,
        handler                     = function(self, data)
            classBuffFilter.Data = data
        end
    }

    property "Refresh"              {
        set                         = "Refresh"
    }

    property "PaddingLeft"          {
        type                        = NaturlNumber,
        default                     = 0,
        handler                     = function(self, paddingLeft)
            self:OnPaddingChanged(paddingLeft)
        end
    }

    property "PaddingRight"         {
        type                        = NaturlNumber,
        default                     = 0,
        handler                     = function(self, paddingRight)
            self:OnPaddingChanged(nil, nil, paddingRight)
        end
    }

    property "PaddingTop"           {
        type                        = NaturlNumber,
        default                     = 0,
        handler                     = function(self, paddingTop)
            self:OnPaddingChanged(nil, paddingTop)
        end
    }

    property "PaddingBottom"        {
        type                        = NaturlNumber,
        default                     = 0,
        handler                     = function(self, paddingBottom)
            self:OnPaddingChanged(nil, nil, nil, paddingBottom)
        end
    }

    property "CheckDispelAbilityEnable"{
        type                        = Boolean,
        default                     = false
    }

    property "SpecID"               {
        type                        = Number,
        default                     = 0,
        handler                     = function(self, specID)
            dispelDebuffFilter.SpecID = specID
        end
    }

    property "BlackAuraList"        {
        type                        = RawTable
    }

    __Template__{
        PixelGlow                   = SpaUI.Widget.PixelGlow
    }
    function __ctor(self)
        self.BuffIcons              = {}
        self.DebuffIcons            = {}
        self.ClassBuffIcons         = {}
        self.DispelDebuffIcons      = {}
        self.BossAuraIcons          = {}

        self.OnSizeChanged = self.OnSizeChanged + OnSizeChanged
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

    -- -- Enlarge debuff icon
    -- [EnlargeDebuffIcon]                                                                 = {
    --     topLevel                                                                        = true,

    --     PixelGlow                                                                       = {
    --         period                                                                      = 2,
    --         visible                                                                     = true
    --     }
    -- },

    -- -- Enlarge buff icon
    -- [EnlargeBuffIcon]                                                                   = {
    --     topLevel                                                                        = true,
    -- },

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