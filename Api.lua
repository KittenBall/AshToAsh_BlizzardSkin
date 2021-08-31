Scorpio "AshToAsh.BlizzardSkin" ""

__Sealed__()
class "AshBlzSkinApi" {}

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitCombineDisconnectedColor()
    return Wow.FromUnitEvent("UNIT_HEALTH", "UNIT_CONNECTION", "UNIT_NAME_UPDATE"):Next():Map(function(unit)
        local _, cls            = UnitClass(unit)
        return UnitIsConnected(unit) and Color[cls or "PALADIN"] or Color.DISABLED
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitCastBarColor()
    return Wow.UnitCastChannel():CombineLatest(Wow.UnitCastInterruptible()):Map(function(channel, interruptible)
        if not interruptible then
            return ColorType(0.7, 0.7, 0.7)
        elseif channel then
            return ColorType(0, 1, 0)
        else
            return ColorType(1, 0.7, 0)
        end
    end)
end