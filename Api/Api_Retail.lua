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
-- Center Status Icon
-------------------------------------------------

SummonStatus = _G.Enum.SummonStatus

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