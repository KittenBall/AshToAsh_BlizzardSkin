Scorpio "AshToAsh.BlizzardSkin.Api.BCC" ""

if not Scorpio.IsBCC then return end

-------------------------------------------------
-- Power start
-------------------------------------------------

local function getDisplayedPowerID(unit)
    return UnitPowerType(unit)
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
        return scolor
    end)
end

-------------------------------------------------
-- Power end
-------------------------------------------------

-------------------------------------------------
-- Vehicle start
-------------------------------------------------

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitVehicleVisible()
    return Wow.FromUnitEvent(Observable:Just("any")):Map(function(unit)
        return false
    end)
end

-------------------------------------------------
-- Vehicle end
-------------------------------------------------

-------------------------------------------------
-- Aura start
-------------------------------------------------

local function isBossAura(...)
    return select(1, ...), select(12, ...)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitBossAura() 
    return Wow.UnitAura():Map(function(unit)
        local hasBossAura = false

        local index = 1
        local name = ""
        while not hasBossAura and name do
            name, hasBossAura = isBossAura(UnitAura(unit, index, "HARMFUL"))
            index = index + 1
        end

        if hasBossAura then return true end

        index = 1
        name = ""
        while not hasBossAura and name do
            name, hasBossAura = isBossAura(UnitAura(unit, index, "HELPFUL"))
            index = index + 1
        end

        return hasBossAura
    end)
end

-------------------------------------------------
-- Aura end
-------------------------------------------------

-------------------------------------------------
-- Center Status start
-------------------------------------------------

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitCenterStatusIconVisible()
    return Wow.FromUnitEvent(CenterStatusSubject):Next():Map(function(unit)
        if UnitInOtherParty(unit) or UnitHasIncomingResurrection(unit) or (UnitIsInDistance(unit) and not UnitInPhase(unit))then
            return true
        end
        return false
    end)
end

-------------------------------------------------
-- Center Status end
-------------------------------------------------

-------------------------------------------------
-- Dispell start
-------------------------------------------------

CLASS_DISPELL_TYPE              = {
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

-- 可驱散Debuff类型
local function isDebuffCanDispell(class, ...)
    local name = select(1, ...)
    local dType = select(4, ...)
    if not name or not dType then return false, name end
    if DispellDebuffTypes[dType] and CLASS_DISPELL_TYPE[class] and CLASS_DISPELL_TYPE[class][dType] then
        return true, name, dType
    end
    return false, name
end

-- 单位是否有玩家能驱散的debuff
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitDebuffCanDispell()
    return Wow.UnitAura():Map(function(unit)
            -- 在副本内才工作
            local inInstance, instanceType = IsInInstance()
            if not inInstance or instanceType == "none" then return false end

            local class = UnitClassBase(unit)
            local canDispell, canDispellType
            local index = 1
            local name = ""

            while not canDispell and name do
                canDispell, name, canDispellType = isDebuffCanDispell(class, UnitAura(unit, index, "HARMFUL|RAID"))
                index = index + 1
            end

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

-------------------------------------------------
-- Dispell end
-------------------------------------------------