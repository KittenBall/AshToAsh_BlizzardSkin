Scorpio "AshToAsh.BlizzardSkin.Api.Power" ""

--@retail@
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
--@end-retail@


--[===[@non-version-retail@
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
--@end-non-version-retail@]===]