Scorpio "AshToAsh.BlizzardSkin.Api.Panel" ""

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
function AshBlzSkinApi.UnitPanelLabelVisible()
    return Wow.GetFrame(AshGroupPanel, "OnSizeChanged"):Map(function(panel)
        local w, h = panel:GetSize()
        if panel.Orientation == Orientation.HORIZONTAL then
            return h >= 40 and w > 20
        else
            return w >= 50 and h > 20
        end
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitPetPanelLabelVisible()
    return Wow.GetFrame(AshGroupPetPanel, "OnSizeChanged"):Map(function(panel)
        local w, h = panel:GetSize()
        if panel.Orientation == Orientation.HORIZONTAL then
            return h >= 40 and w > 20
        else
            return w >= 50 and h > 20
        end
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