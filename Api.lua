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

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitCastBarColor()
    local nonInterruptibleColor = ColorType(0.7, 0.7, 0.7)
    local channelColor = ColorType(0, 1, 0)
    local castColor = ColorType(1, 0.7, 0)
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

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitIsPlayer()
    return Wow.Unit():Map(function(unit)
        return UnitIsPlayer(unit) or UnitTreatAsPlayerForDisplay(unit)
    end)
end

-- 职业可驱散debuff类型
-- { Magic = true, Curse = true, Disease = true, Poison = true }

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
local dispellDebuffTypes    = { Magic = true, Curse = true, Disease = true, Poison = true }
local function isDebuffCanDispell(specID, dType)
    if dispellDebuffTypes[dType] and CLASS_DISPELL_TYPE[specID] and CLASS_DISPELL_TYPE[specID][dType] then
        return true
    end
    return false
end

-- 单位是否有能驱散的debuff
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitDebuffCanDispell()
    return Wow.UnitAura():Map(function(unit)
        local canDispell, canDispellType
        local inInstance, instanceType = IsInInstance()
        -- 在副本内才工作
        if inInstance and (instanceType == "party" or instanceType == "raid" or instanceType == "scenario") then
            local specID = GetSpecializationInfo(GetSpecialization())
            AuraUtil.ForEachAura(unit, "HARMFUL|RAID", 1, function(_, _, _, dType)
                if isDebuffCanDispell(specID, dType) then
                    canDispell = true
                    canDispellType = dType
                    return true
                end
                return false
            end)
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

-- Center status
local centerStatusSubject = BehaviorSubject()
centerStatusSubject:OnNext("any")

__SystemEvent__ "INCOMING_RESURRECT_CHANGED" "UNIT_OTHER_PARTY_CHANGED" "UNIT_PHASE" "UNIT_FLAGS" "UNIT_CTR_OPTIONS" "INCOMING_SUMMON_CHANGED"
function UpdateCenterStatusIcon(unit)
    centerStatusSubject:OnNext(unit)
end

local function unitInDistance(unit)
	local distance, checkedDistance = UnitDistanceSquared(unit);

	if ( checkedDistance ) then
		return distance < DISTANCE_THRESHOLD_SQUARED
	end
end

function AshBlzSkinApi.UnitInDistance()
    return Wow.FromUnitEvent(Observable.Interval(0.5):Map("=>'any'")):Map(function(unit)
        return unit, UnitIsUnit(unit, "player") or not (UnitInParty(unit) or UnitInRaid(unit)) or unitInDistance(unit)
    end)
end

local unitInDistanceMap = {}
AshBlzSkinApi.UnitInDistance():Subscribe(function(unit, inDistance)
    if unitInDistanceMap[unit] ~= inDistance then
        unitInDistanceMap[unit] = inDistance
        centerStatusSubject:OnNext(unit)
    end
end)

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitCenterStatusIconVisible()
    return Wow.FromUnitEvent(centerStatusSubject):Map(function(unit)
        if UnitInOtherParty(unit) or UnitHasIncomingResurrection(unit) or UnitPhaseReason(unit) then
            return true
        elseif C_IncomingSummon.HasIncomingSummon(unit) then
            local staus = C_IncomingSummon.IncomingSummonStatus(unit)
            return status == Enum.SummonStatus.Pending or staus == Enum.SummonStatus.Accepted or staus == Enum.SummonStatus.Declined
        end
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitCenterStatusIconUpdate()
    local texture = {}
    local border = {}
    local sRect = RectType()
    local tooltip
    return Wow.FromUnitEvent(centerStatusSubject):Map(function(unit)
        wipe(texture)
        wipe(border)
        if UnitInOtherParty(unit) then
            texture.file = "Interface\\LFGFrame\\LFG-Eye"
            sRect.left, sRect.right, sRect.top, sRect.bottom = 0.125, 0.25, 0.25, 0.5
            border.file = "Interface\\Common\\RingBorder"
            border.visible = true
            tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE
        elseif UnitHasIncomingResurrection(unit) then
            texture.file = "Interface\\RaidFrame\\Raid-Icon-Rez"
            sRect.left, sRect.right, sRect.top, sRect.bottom = 0, 1, 0, 1
            border.visible = false
            tooltip = nil
        elseif C_IncomingSummon.HasIncomingSummon(unit) then
            if status == Enum.SummonStatus.Pending then
                texture.atlas = "Raid-Icon-SummonPending"
                sRect.left, sRect.right, sRect.top, sRect.bottom = 0, 1, 0, 1
                border.visible = false
                tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_PENDING
			elseif( status == Enum.SummonStatus.Accepted ) then
                texture.atlas = "Raid-Icon-SummonAccepted"
                sRect.left, sRect.right, sRect.top, sRect.bottom = 0, 1, 0, 1
                border.visible = false
                tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_ACCEPTED
			elseif( status == Enum.SummonStatus.Declined ) then
                texture.atlas = "Raid-Icon-SummonDeclined"
                sRect.left, sRect.right, sRect.top, sRect.bottom = 0, 1, 0, 1
                border.visible = false
                tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_DECLINED
			end
        else
            local phaseReason = UnitPhaseReason(unit);
            if phaseReason then
                texture.file = "Interface\\TargetingFrame\\UI-PhasingIcon"
                sRect.left, sRect.right, sRect.top, sRect.bottom = 0.15625, 0.84375, 0.15625, 0.84375
                border.visible = false
                tooltip = PartyUtil.GetPhasedReasonString(phaseReason, unit)
            end
        end

        texture.texCoords = sRect
        return texture, border, tooltip
    end)
end
-- Center status