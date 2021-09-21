Scorpio "AshToAsh.BlizzardSkin.Api.Retail" ""

if not Scorpio.IsRetail then return end 

-------------------------------------------------
-- Power
-------------------------------------------------

local function getDisplayedPowerID(unit)
    local barInfo = GetUnitPowerBarInfo(unit)
    if ( barInfo and barInfo.showOnRaid and (UnitInParty(unit) or UnitInRaid(unit)) ) then
        return ALTERNATE_POWER_INDEX
    else
        return UnitPowerType(unit)
    end
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPower(frequent)
    return Wow.FromUnitEvent(frequent and "UNIT_POWER_FREQUENT" or "UNIT_POWER_UPDATE", "UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_POWER_BAR_SHOW", "UNIT_POWER_BAR_HIDE")
        :Next():Map(function(unit)
            return UnitPower(unit, getDisplayedPowerID(unit))
        end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPowerMax()
    local minMax                = { min = 0 }
    return Wow.FromUnitEvent("UNIT_MAXPOWER", "UNIT_DISPLAYPOWER", "UNIT_POWER_BAR_SHOW", "UNIT_POWER_BAR_HIDE")
        :Map(function(unit) minMax.max =  UnitPowerMax(unit, getDisplayedPowerID(unit)) return minMax end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPowerColor()
    local scolor                = Color(1, 1, 1)
    return Wow.FromUnitEvent("UNIT_CONNECTION", "UNIT_DISPLAYPOWER", "UNIT_POWER_BAR_SHOW", "UNIT_POWER_BAR_HIDE")
        :Map(function(unit)
            if not UnitIsConnected(unit) then
                scolor.r        = 0.5
                scolor.g        = 0.5
                scolor.b        = 0.5
            else
                local barInfo = GetUnitPowerBarInfo(unit)
                if ( barInfo and barInfo.showOnRaid ) then
                    local _, _, r, g, b = UnitPowerType(unit, ALTERNATE_POWER_INDEX)
                    if r then
                        scolor.r    = r
                        scolor.g    = g
                        scolor.b    = b
                    else
                        scolor.r, scolor.g, scolor.b = 0.7, 0.7, 0.6
                    end
                else
                    local _, ptoken, r, g, b = UnitPowerType(unit)
                    local color     = ptoken and Color[ptoken]
                    if color then return color end

                    if r then
                        scolor.r    = r
                        scolor.g    = g
                        scolor.b    = b
                    else
                        return Color.MANA
                    end
                end
            end
            return scolor
        end)
end

-------------------------------------------------
-- Vehicle
-------------------------------------------------

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitVehicleVisible()
    return Wow.FromUnitEvent(Wow.FromEvent("GROUP_ROSTER_UPDATE", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE"):Map("unit => unit or 'any'")):Map(function(unit)
        return UnitInVehicle(unit) and UnitHasVehicleUI(unit)
    end)
end

-------------------------------------------------
-- Aura
-------------------------------------------------

-- 是否有Boss给的Aura
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitBossAura()
    return Wow.UnitAura():Map(function(unit)
        local hasBossAura = false

        AuraUtil.ForEachAura(unit, "HARMFUL", 1, function(...)
            if select(12, ...) then
                hasBossAura = true
                return true
            end
            return false
        end)

        if hasBossAura then return true end

        AuraUtil.ForEachAura(unit, "HELPFUL", 1, function(...)
            if select(12, ...) then
                hasBossAura = true
                return true
            end
            return false
        end)

        return hasBossAura
    end)
end

-------------------------------------------------
-- Center Status Icon
-------------------------------------------------

SummonStatus = _G.Enum

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitCenterStatusIconVisible()
    return Wow.FromUnitEvent(CenterStatusSubject):Next():Map(function(unit)
        if UnitInOtherParty(unit) or UnitHasIncomingResurrection(unit) or (UnitIsInDistance(unit) and UnitPhaseReason(unit)) then
            return true
        elseif C_IncomingSummon.HasIncomingSummon(unit) then
            local staus = C_IncomingSummon.IncomingSummonStatus(unit)
            return status == SummonStatus.Pending or staus == SummonStatus.Accepted or staus == SummonStatus.Declined
        end
        return false
    end)
end

-------------------------------------------------
-- Dispell
-------------------------------------------------
-- 职业可驱散debuff类型
CLASS_DISPELL_TYPE              = {
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


-- 可驱散Debuff类型
local function isDebuffCanDispell(specID, dType)
    if DispellDebuffTypes[dType] and CLASS_DISPELL_TYPE[specID] and CLASS_DISPELL_TYPE[specID][dType] then
        return true
    end
    return false
end

-- 单位是否有玩家能驱散的debuff
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitDebuffCanDispell()
    return Wow.UnitAura():Map(function(unit)
            -- 在副本内才工作
            local inInstance, instanceType = IsInInstance()
            if not inInstance or instanceType == "none" then return false end
            local canDispell, canDispellType
            local specID = GetSpecializationInfo(GetSpecialization())
            AuraUtil.ForEachAura(unit, "HARMFUL|RAID", 1, function(_, _, _, dType)
                if isDebuffCanDispell(specID, dType) then
                    canDispell = true
                    canDispellType = dType
                    return true
                end
                return false
            end)
            return canDispell or false, canDispellType
        end)
end


-- 单位可驱散的Debuff颜色
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitDebuffCanDispellColor()
    return AshBlzSkinApi.UnitDebuffCanDispell():Map(function(_, dType)
        return DebuffTypeColor[dType or ""]
    end)
end