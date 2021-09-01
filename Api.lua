Scorpio "AshToAsh.BlizzardSkin" ""

namespace "AshToAsh.Skin.Blizzard"

__Sealed__()
interface "AshBlzSkinApi" {}

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitColor()
    return Wow.FromUnitEvent("UNIT_CONNECTION", "UNIT_NAME_UPDATE"):Map(function(unit)
        if not UnitIsConnected(unit) then
            return Color.GRAY
        else
            local _, cls            = UnitClass(unit)
            if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit)  then
                return Color[cls or "PALADIN"]
            elseif not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
                return ColorType(0.9, 0.9, 0.9)
            elseif UnitIsFriend("player", unit) then
                return Color[cls or "GREEN"]
            elseif UnitCanAttack("player", unit) then
                return Color.RED
            else
                return ColorType(UnitSelectionColor(unit, true))
            end
        end
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

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitVehicleVisible()
    return Wow.FromUnitEvent(Wow.FromEvent("GROUP_ROSTER_UPDATE", "UNIT_ENTERED_VEHICLE", "UNIT_EXITED_VEHICLE"):Map("unit => unit or 'any'")):Map(function(unit)
        return UnitInVehicle(unit) and UnitHasVehicleUI(unit)
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitIsDead()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_HEALTH", "UNIT_CONNECTION", "PLAYER_FLAGS_CHANGED")):Next():Map(function(unit)
        return UnitIsDeadOrGhost(unit) and UnitIsConnected(unit)
    end)
end

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