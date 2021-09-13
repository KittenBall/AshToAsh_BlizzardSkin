Scorpio "AshToAsh.BlizzardSkin" ""

namespace "AshToAsh.Skin.Blizzard"

SKIN_NAME = "AshToAsh.BlizzardSkin"
Style.RegisterSkin(SKIN_NAME)


__Sealed__()
interface "AshBlzSkinApi" {}

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitColor()
    local shareColor = Color(1, 1, 1, 1)
    local tapDeniedColor = ColorType(0.9, 0.9, 0.9)
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

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitIsPlayer()
    return Wow.Unit():Map(function(unit)
        return UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit)
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetOwnerName()
    return Wow.Unit():Map(function(unit)
        if not unit then return end
        local getTipLines = GetGameTooltipLines("Unit", unit)
        local _, left = getTipLines(_, 1)
        return left
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitInRange()
    return Wow.FromUnitEvent(Observable.Interval(0.5):Map("=>'any'")):Map(function(unit)
        return UnitIsUnit(unit, "player") or UnitInRange(Unit)
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetInRange()
    return Wow.FromUnitEvent(Observable.Interval(0.5):Map("=>'any'")):Map(function(unit)
        return UnitInRange(unit) or not IsInGroup()
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetThreatLevel()
    return Wow.FromUnitEvent("UNIT_THREAT_SITUATION_UPDATE"):Map(function(unit)
        return UnitExists(unit) and UnitThreatSituation(unit) or 0
    end)
end
-------------------------------------------------
-- CastBar start
-------------------------------------------------

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitCastBarColor()
    local channelColor = ColorType(0, 1, 0)
    local castColor = ColorType(1, 0.7, 0)
    return Wow.UnitCastChannel():Map(function(channel)
        if channel then
            return channelColor
        else
            return castColor
        end
    end)
end

-------------------------------------------------
-- CastBar end
-------------------------------------------------

-------------------------------------------------
-- Dead start
-------------------------------------------------
local deadSubject = BehaviorSubject()

__SystemEvent__ "UNIT_CONNECTION" "PLAYER_FLAGS_CHANGED"
function UpdateDeadStatus(unit)
    deadSubject:OnNext(unit)
end

-- 抄的Scorpio UnitApi
__CombatEvent__ "UNIT_DIED" "UNIT_DESTROYED" "UNIT_DISSIPATES"
function COMBAT_UNIT_DIED(_, event, _, _, _, _, _, destGUID)
    for unit in Scorpio.GetUnitsFromGUID(destGUID) do
        deadSubject:OnNext(unit)
    end
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitIsDead()
    return Wow.FromUnitEvent(deadSubject):Map(function(unit)
        return UnitIsDeadOrGhost(unit) and UnitIsConnected(unit)
    end)
end
-------------------------------------------------
-- Dead end
-------------------------------------------------

-------------------------------------------------
-- Dispell start
-------------------------------------------------

DispellDebuffTypes    = { Magic = true, Curse = true, Disease = true, Poison = true }

-------------------------------------------------
-- Dispell end
-------------------------------------------------

-------------------------------------------------
-- Center Status start
-------------------------------------------------
CenterStatusSubject = BehaviorSubject()
CenterStatusSubject:OnNext("any")

__SystemEvent__ "INCOMING_RESURRECT_CHANGED" "UNIT_OTHER_PARTY_CHANGED" "UNIT_PHASE" "UNIT_FLAGS" "UNIT_CTR_OPTIONS" "INCOMING_SUMMON_CHANGED"
function UpdateCenterStatusIcon(unit)
    CenterStatusSubject:OnNext(unit)
end

local function unitInDistance(unit)
	local distance, checkedDistance = UnitDistanceSquared(unit);

	if ( checkedDistance ) then
		return distance < DISTANCE_THRESHOLD_SQUARED
	end
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitInDistance()
    return Wow.FromUnitEvent(Observable.Interval(0.5):Map("=>'any'")):Map(function(unit)
        return unit, UnitIsUnit(unit, "player") or not (UnitInParty(unit) or UnitInRaid(unit)) or unitInDistance(unit)
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitInDistanceChanged()
    local unitInDistanceMap = {}
    return AshBlzSkinApi.UnitInDistance():Where(function(unit, inDistance)
        if unitInDistanceMap[unit] ~= inDistance then
            unitInDistanceMap[unit] = inDistance
            return true
        end
    end):Map(function(unit, inDistance) return inDistance end)
end

-------------------------------------------------
-- Center Status end
-------------------------------------------------

-------------------------------------------------
-- Classic
-------------------------------------------------
if Scorpio.IsRetail then return end
GetThreatStatusColor = _G.GetThreatStatusColor or function (index) if index == 3 then return 1, 0, 0 elseif index == 2 then return 1, 0.6, 0 elseif index == 1 then return 1, 1, 0.47 else return 0.69, 0.69, 0.69 end end
UnitTreatAsPlayerForDisplay = Toolset.fakefunc