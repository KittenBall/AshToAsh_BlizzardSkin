Scorpio "AshToAsh.BlizzardSkin" ""

namespace "AshToAsh.Skin.Blizzard"

__Sealed__()
interface "AshBlzSkinApi" {}

local tapDeniedColor = ColorType(0.9, 0.9, 0.9)

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitColor()
    local shareColor = Color(1, 1, 1, 1)
    return Wow.FromUnitEvent("UNIT_CONNECTION", "UNIT_NAME_UPDATE"):Map(function(unit)
        if not UnitIsConnected(unit) then
            return Color.GRAY
        else
            local _, cls            = UnitClass(unit)
            if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit)  then
                return Color[cls or "PALADIN"]
            elseif not UnitPlayerControlled(unit) and UnitIsTapDenied(unit) then
                return tapDeniedColor
            elseif UnitIsFriend("player", unit) then
                return Color[cls or "GREEN"]
            elseif UnitCanAttack("player", unit) then
                return Color.RED
            else
                shareColor.r, shareColor.g, shareColor.b, shareColor.a = UnitSelectionColor(unit, true)
                return shareColor
            end
        end
    end)
end

local nonInterruptibleColor = ColorType(0.7, 0.7, 0.7)
local channelColor = ColorType(0, 1, 0)
local castColor = ColorType(1, 0.7, 0)

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitCastBarColor()
    return Wow.UnitCastChannel():CombineLatest(Wow.UnitCastInterruptible()):Map(function(channel, interruptible)
        if not interruptible then
            return nonInterruptibleColor
        elseif channel then
            return channelColor
        else
            return castColor
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