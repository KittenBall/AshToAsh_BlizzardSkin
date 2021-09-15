Scorpio "AshToAsh.BlizzardSkin" ""

namespace "AshToAsh.Skin.Blizzard"

SKIN_NAME = "AshToAsh.BlizzardSkin"
Style.RegisterSkin(SKIN_NAME)

__Sealed__()
interface "AshBlzSkinApi" {}

class "LruCache"(function(_ENV)

    __Arguments__(NaturalNumber)
    function __new(_, capacity)
        if capacity <= 0 then
            capacity = 1
        end

        local head = {}
        local tail = {}
        head.next = tail
        tail.pre = head
        return {Capacity = capacity, Cache = {}, Head = head, Tail = tail, CacheSize = 0}
    end

    __Arguments__(NEString)
    function __index(self, key)
        local cache = self.Cache
        local node = cache[key]
        if node then
            node.pre.next = node.next
            node.next.pre = node.pre

            self.Tail.pre.next = node
            node.next = self.Tail
            node.pre = self.Tail.pre
            self.Tail.pre = node
            return node.value
        end
        return -1
    end

    __Arguments__{NEString, Any/nil}
    function __newindex(self, key, value)
        if self[key] ~= -1 then
            self.Tail.pre.value = value
        else
            if self.CacheSize == self.Capacity then
                self.Cache[self.Head.next.key] = nil
                self.CacheSize = self.CacheSize - 1
                self.Head.next = self.Head.next.next
                self.Head.next.pre = self.Head 
            end

            local node  = {}
            node.key = key
            node.value = value
            
            self.Tail.pre.next = node
            node.pre = self.Tail.pre
            node.next = self.Tail
            self.Tail.pre = node

            self.Cache[key] = node
            self.CacheSize = self.CacheSize + 1
        end
    end
end)

-------------------------------------------------
-- Panel start
-------------------------------------------------

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPanelConfigChanged()
    return Wow.GetFrame(AshGroupPanel, Wow.FromEvent("ASHTOASH_CONFIG_CHANGED"))
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetPanelConfigChanged()
    return Wow.GetFrame(AshGroupPetPanel, Wow.FromEvent("ASHTOASH_CONFIG_CHANGED"))
end

local function getFilterDesc(filter)
    if filter and #filter == 1 then
        return filter[1]
    end
end

local function concatFilterDesc(...)
    local desc
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        if value then
            if desc then
                desc = desc .. "|cffffffff&|r" .. value
            else
                desc = value
            end
        end
    end
    return desc
end

local function getVerticalFilterDesc(panel)
    local group = getFilterDesc(panel.GroupFilter)
    if group then
        group = GROUP_NUMBER:format(group)
    end

    local class = getFilterDesc(panel.ClassFilter)
    if class then
        class = Color[class] .. LOCALIZED_CLASS_NAMES_MALE[class] .. FONT_COLOR_CODE_CLOSE
    end

    local desc = concatFilterDesc(group, class)
    
    if not desc then
        local role = getFilterDesc(panel.RoleFilter)
        if role then
            desc = _G[strupper(role)]
        end
    end

    return desc
end

local function addBreakLine(text)
    return XList(UTF8Encoding.Decodes(text)):Map(UTF8Encoding.Encode):Join("\n")
end

local function getHorizontalFilterDesc(panel)
    local group = getFilterDesc(panel.GroupFilter)
    if group then
        return addBreakLine(GROUP_NUMBER:format(group))
    end

    local class = getFilterDesc(panel.ClassFilter)
    if class then
        return Color[class] .. addBreakLine(LOCALIZED_CLASS_NAMES_MALE[class]) .. FONT_COLOR_CODE_CLOSE
    end

    local role = getFilterDesc(panel.RoleFilter)
    if role then
        return addBreakLine(_G[strupper(role)])
    end
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPanelLabel()
    return AshBlzSkinApi.UnitPanelConfigChanged():Map(function(panel)
        if panel.Orientation == Orientation.HORIZONTAL then
            return getHorizontalFilterDesc(panel)
        else
            return getVerticalFilterDesc(panel)
        end
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetPanelLabel()
    return AshBlzSkinApi.UnitPetPanelConfigChanged():Map(function(panel)
        if panel.Orientation == Orientation.HORIZONTAL then
            return addBreakLine(PET)
        else
            return PET
        end
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPanelOrientation()
    return AshBlzSkinApi.UnitPanelConfigChanged():Map(function(panel)
        return panel and panel.Orientation
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPanelVisible()
    return Wow.FromFrameSize(AshGroupPanel):Map(function(w, h)
        return w > 20 and h > 20
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetPanelVisible()
    return Wow.FromFrameSize(AshGroupPetPanel):Map(function(w, h)
        return w > 20 and h > 20
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetPanelOrientation()
    return AshBlzSkinApi.UnitPetPanelConfigChanged():Map(function(panel)
        return panel and panel.Orientation
    end)
end


-------------------------------------------------
-- Panel end
-------------------------------------------------

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitColor()
    local shareColor = Color(1, 1, 1, 1)
    local tapDeniedColor = ColorType(0.9, 0.9, 0.9)
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_CONNECTION", "UNIT_NAME_UPDATE", "GROUP_ROSTER_UPDATE"):Map("unit => unit or 'any'")):Next():Map(function(unit)
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
function AshBlzSkinApi.UnitInRange()
    return Wow.FromUnitEvent(Observable.Interval(0.5):Map("=>'any'")):Map(function(unit)
        return UnitIsUnit(unit, "player") or UnitInRange(Unit)
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
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitIsDead()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_CONNECTION", "PLAYER_FLAGS_CHANGED", "UNIT_HEALTH")):Next():Map(function(unit)
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
Observable.Interval(1):Subscribe(function() CenterStatusSubject:OnNext("any") end)

__SystemEvent__ "INCOMING_RESURRECT_CHANGED" "UNIT_OTHER_PARTY_CHANGED" "UNIT_PHASE" "UNIT_FLAGS" "UNIT_CTR_OPTIONS" "INCOMING_SUMMON_CHANGED" "GROUP_ROSTER_UPDATE" "PLAYER_ENTERING_WORLD" "UNIT_PET"
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

-------------------------------------------------
-- Center Status end
-------------------------------------------------

-------------------------------------------------
-- Classic
-------------------------------------------------
if Scorpio.IsRetail then return end
GetThreatStatusColor = _G.GetThreatStatusColor or function (index) if index == 3 then return 1, 0, 0 elseif index == 2 then return 1, 0.6, 0 elseif index == 1 then return 1, 1, 0.47 else return 0.69, 0.69, 0.69 end end
UnitTreatAsPlayerForDisplay = Toolset.fakefunc