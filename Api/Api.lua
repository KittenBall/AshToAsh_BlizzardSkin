Scorpio "AshToAsh.BlizzardSkin.Api" ""

-------------------------------------------------
-- Unit
-------------------------------------------------

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitColor()
    local shareColor = Color(1, 1, 1, 1)
    local tapDeniedColor = ColorType(0.9, 0.9, 0.9)
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_CONNECTION", "UNIT_NAME_UPDATE", "GROUP_ROSTER_UPDATE"):Map("unit => unit or 'any'")):Next():Map(function(unit)
        unit = Wow.GetUnitOwner(unit)
        if not UnitIsConnected(unit) then
            return Color.GRAY
        else
            local _, cls            = UnitClass(unit)
            if UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit) then
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
function AshBlzSkinApi.UnitIsFocus()
    return Wow.FromUnitEvent(Wow.FromEvent("PLAYER_FOCUS_CHANGED"):Map("=> 'any'")):Map(function(unit)
        return UnitIsUnit(unit, "focus")
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitInRange()
    return Wow.UnitTimer():Map(function(unit)
        if not UnitExists(unit) then return false end
        if UnitIsUnit(unit, "player") then
            return true
        else
            local inRange, checkedRange = UnitInRange(unit)
            return not (checkedRange and not inRange)
        end
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitAura()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_AURA", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED"):Map("unit => unit or 'any'")):Next()
end

-------------------------------------------------
-- CastBar
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
-- Status
-------------------------------------------------

--@retail@
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitStatus()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_CONNECTION", "PLAYER_FLAGS_CHANGED", "UNIT_HEALTH"))
end
--@end-retail@

--[===[@non-version-retail@
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitStatus()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_CONNECTION", "PLAYER_FLAGS_CHANGED", "UNIT_HEALTH", "UNIT_HEALTH_FREQUENT"))
end
--@end-non-version-retail@]===]

-------------------------------------------------
-- Dispell
-------------------------------------------------

__Static__() __AutoCache__()
function AshBlzSkinApi.CheckDispelAbilityEnable()
    return Wow.FromUnitEvent(Wow.FromEvent("PLAYER_ENTERING_WORLD"):Map("=> 'any'")):Map(function()
        local inInstance, instanceType = IsInInstance()
        if not inInstance or instanceType == "none" or instanceType == "pvp" then return false end

        return true
    end)
end

-------------------------------------------------
-- Center Status
-------------------------------------------------

CenterStatusSubject = BehaviorSubject()
Observable.Interval(1):Subscribe(function() CenterStatusSubject:OnNext("any") end)

__SystemEvent__ "INCOMING_RESURRECT_CHANGED" "UNIT_OTHER_PARTY_CHANGED" "UNIT_PHASE" "UNIT_FLAGS" "UNIT_CTR_OPTIONS" "INCOMING_SUMMON_CHANGED" "PLAYER_ENTERING_WORLD" "UNIT_PET"
function UpdateCenterStatusIcon(unit)
    CenterStatusSubject:OnNext(unit or "any")
end

function UnitIsInDistance(unit)
    if UnitIsUnit(unit, "player") then return true end

    if UnitIsPlayer(unit) then
	    local distance, checkedDistance = UnitDistanceSquared(unit)

	    if ( checkedDistance ) then
	    	return distance < DISTANCE_THRESHOLD_SQUARED
	    end
    end

    return false
end

--@retail@

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitCenterStatus()
    return Wow.FromUnitEvent(CenterStatusSubject):Next()
end
--@end-retail@

--[===[@non-version-retail@
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitCenterStatus()
    return Wow.FromUnitEvent(CenterStatusSubject):Next()
end
--@end-non-version-retail@]===]

-------------------------------------------------
-- Leader, Assistant, MasterLooter etc
-------------------------------------------------
--[===[@non-version-retail@
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitIsMasterLooter()
    return Wow.Unit():Next():Map(function(unit)
        if UnitExists(unit) then
            local raidIndex = UnitInRaid(unit)
            if raidIndex then
                local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, loot = GetRaidRosterInfo(raidIndex)
                return loot
            end
        end
        return false
    end)
end
--@end-non-version-retail@]===]

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitIsLeaderOrAssistant()
    return Wow.FromUnitEvent(Wow.FromEvent("PARTY_LEADER_CHANGED"):Map("=> 'any'")):Next():Map(function(unit)
        if UnitExists(unit) then
            local raidIndex = UnitInRaid(unit)
            if raidIndex then
                local name, rank, subgroup, level, class, fileName, zone, online, isDead, role, loot = GetRaidRosterInfo(raidIndex)
                return (rank and rank > 0) and rank or false
            end
        end
        return false
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitIsLeaderOrAssistantIcon()
    return AshBlzSkinApi.UnitIsLeaderOrAssistant():Map(function(rank)
        if rank == 2 then
            return "Interface\\GroupFrame\\UI-Group-LeaderIcon"
        elseif rank == 1 then
            return "Interface\\GroupFrame\\UI-Group-AssistantIcon"
        end
    end)
end

-------------------------------------------------
-- Specialization
-------------------------------------------------

--@retail@
__Static__() __AutoCache__()
function AshBlzSkinApi.PlayerSpecializationID()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        return GetSpecializationInfo(GetSpecialization()) or 0
    end)
end
--@end-retail@

--[===[@non-version-retail@
__Static__() __AutoCache__()
function AshBlzSkinApi.PlayerSpecializationID()
    return Wow.FromUnitEvent(Observable:Just("any")):Map(function(unit)
        return 0
    end)
end
--@end-non-version-retail@]===]

-------------------------------------------------
-- Ready check
-------------------------------------------------

__Static__() __AutoCache__()
function AshBlzSkinApi.ReadyCheck()
    return Wow.FromUnitEvent(Wow.FromEvent("READY_CHECK_CONFIRM", "READY_CHECK"):Map("=> 'any'"))
end

__Static__() __AutoCache__()
function AshBlzSkinApi.ReadyCheckFinish()
    return Wow.FromUnitEvent(Wow.FromEvent("READY_CHECK_FINISHED"):Map("=> 'any'"))
end

-------------------------------------------------
-- Option
-------------------------------------------------

__Static__() __AutoCache__()
function AshBlzSkinApi.PowerBarVisible()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        return DB().Appearance.PowerBar.Visibility == Visibility.SHOW_ALWAYS
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.DisplayOnlyDispellableDebuffs()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        return DB().Appearance.DisplayOnlyDispellableDebuffs
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.HealthBarTexture()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        local texture = GetLibSharedMediaTexture("StatusBar", DB().Appearance.HealthBar.Texture)
        return texture or "Interface\\RaidFrame\\Raid-Bar-Hp-Fill"
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.PowerBarTexture()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        local texture = GetLibSharedMediaTexture("StatusBar", DB().Appearance.PowerBar.Texture)
        return texture or "Interface\\RaidFrame\\Raid-Bar-Resource-Fill"
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.PowerBarBackground()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        local texture = GetLibSharedMediaTexture("Background", DB().Appearance.PowerBar.Background)
        return texture or "Interface\\RaidFrame\\Raid-Bar-Resource-Background"
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitFrameBackground()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        local texture = GetLibSharedMediaTexture("Background", DB().Appearance.Background)
        return texture or "Interface\\RaidFrame\\Raid-Bar-Hp-Bg"
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.CastBarTexture()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        local texture = GetLibSharedMediaTexture("StatusBar", DB().Appearance.CastBar.Texture)
        return texture or "Interface\\TargetingFrame\\UI-StatusBar"
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.AuraTooltipEnable()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        return not DB().Appearance.Aura.DisableTooltip
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.AuraHideCountdownNumbers()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        return not DB().Appearance.Aura.ShowCountdownNumbers
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.DisplayDispellableDebuffHighlight()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        return DB().Appearance.DisplayDispellableDebuffHighlight
    end)
end