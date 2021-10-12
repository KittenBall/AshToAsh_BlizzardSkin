Scorpio "AshToAsh.BlizzardSkin.ImprovedPanel" ""

AUTO_ATTACH_MARGIN_MIN = -100
AUTO_ATTACH_MARGIN_MAX = 100

-- 停止移动时，显示依附关系指示器
-- 同时，如果非主动移动（按住Alt），恢复原来的依附关系
local function OnMaskStopMoving(self)
    local parent = self:GetParent()
    if parent then
        -- 非主动移动，恢复原位置
        if parent.AshToAshBlzSkinLocation then
            CharSV().Panels[parent.Index].Style.location = parent.AshToAshBlzSkinLocation
            Style[parent].location = parent.AshToAshBlzSkinLocation
        end

        if parent:GetNumPoints() > 1 then return end

        local point, relativeTo, relativePoint = parent:GetPoint(1)
        local indicator = self:GetPropertyChild("IconTexture")
        if Class.Validate(getmetatable(Scorpio.UI.GetProxyUI(relativeTo)), Scorpio.Secure.UnitFrame) then
            indicator:ClearAllPoints()

            if point == "TOPLEFT" and relativePoint == "TOPRIGHT" then
                indicator:SetPoint("TOPRIGHT", self, "TOPLEFT", 9, 0)
                indicator:SetTexture[[Interface\AddOns\AshToAsh_BlizzardSkin\Media\indicator_arrow_left]]
            elseif point == "TOPLEFT" and relativePoint == "BOTTOMLEFT" then
                indicator:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, -9)
                indicator:SetTexture[[Interface\AddOns\AshToAsh_BlizzardSkin\Media\indicator_arrow_top]]
            elseif point == "BOTTOMLEFT" and relativePoint == "TOPLEFT" then
                indicator:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 9)
                indicator:SetTexture[[Interface\AddOns\AshToAsh_BlizzardSkin\Media\indicator_arrow_bottom]]
            elseif point == "TOPRIGHT" and relativePoint == "TOPLEFT" then
                indicator:SetPoint("TOPLEFT", self, "TOPRIGHT", -9, 0)
                indicator:SetTexture[[Interface\AddOns\AshToAsh_BlizzardSkin\Media\indicator_arrow_right]]
            end

            indicator:Show()
        else
            indicator:Hide()
        end

        self:SetFrameLevel(8 + (parent.Index or 0 ))
    end
end

local function OnMaskShow(self)
    local parent = self:GetParent()
    if parent then
        parent.AshToAshBlzSkinLocation = nil
    end
    OnMaskStopMoving(self)
end

local function OnMaskStartMoving(self)
    local indicator = self:GetPropertyChild("IconTexture")
    if indicator then
        indicator:Hide()
    end
end

local function PanelStartMoving(self)
    if IsAltKeyDown() then
        self.AshToAshBlzSkinLocation = nil
        self:AshToAshBlzSkinOStartMoving()
    else
        -- 保存原来的位置，因为即使不移动，仍然会触发OnStopMoving
        self.AshToAshBlzSkinLocation = CharSV().Panels[self.Index].Style.location
        self.AshToAhBlzSkinMoving = false
    end
end

local function OnMaskParentChanged(self, parent)
    if parent and Class.Validate(getmetatable(Scorpio.UI.GetProxyUI(parent)), Scorpio.Secure.UnitFrame) then
        if not parent.AshToAshBlzSkinOStartMoving then
            parent.AshToAshBlzSkinOStartMoving = parent.StartMoving
            parent.StartMoving = PanelStartMoving
        end
    end
end

-- make mask frame strata lower
local function OnInit(self, mask)
    mask.OnShow = mask.OnShow + OnMaskShow
    mask.OnStopMoving = mask.OnStopMoving + OnMaskStopMoving
    mask.OnStartMoving = mask.OnStartMoving + OnMaskStartMoving
    mask.OnParentChanged = mask.OnParentChanged + OnMaskParentChanged

    Style[mask]             = {
        frameStrata         = "DIALOG",

        Label               = {
            text            = L["panel_mask_tips"],
            fontObject      = GameFontWhiteTiny,
            justifyH        = "CENTER",
            justifyV        = "TOP",
            location        = {
                Anchor("TOPLEFT", 8, -8),
                Anchor("BOTTOMRIGHT", -8, 8)
            }
        },

        Label1              = {
            text            = L["panel_moving_tips"],
            fontObject      = GameFontWhiteTiny,
            justifyH        = "CENTER",
            justifyV        = "BOTTOM",
            location        = {
                Anchor("TOPLEFT", 8, -8),
                Anchor("BOTTOMRIGHT", -8, 8)
            }
        },

        IconTexture         = {
            size            = Size(22, 22),
            subLevel        = 7,
            vertexColor     = Color.RED
        }
    }
end

function OnEnable()
    RECYCLE_MASKS.OnInit = RECYCLE_MASKS.OnInit + OnInit
end

local function getPanelAutoAttachMargin(panel)
    if panel:GetNumPoints() > 1 then return nil end

    local point, relativeTo, relativePoint, x, y = panel:GetPoint(1)
    if Class.Validate(getmetatable(Scorpio.UI.GetProxyUI(relativeTo)), Scorpio.Secure.UnitFrame) then

        if point == "TOPLEFT" and relativePoint == "TOPRIGHT" then
            return x
        elseif point == "TOPLEFT" and relativePoint == "BOTTOMLEFT" then
            return y
        elseif point == "BOTTOMLEFT" and relativePoint == "TOPLEFT" then
            return y
        elseif point == "TOPRIGHT" and relativePoint == "TOPLEFT" then
            return x
        end
    end

    return nil
end

local function setPanelAutoAttachMargin(panel, margin)
    if panel:GetNumPoints() > 1 or InCombatLockdown() then return end

    if margin > AUTO_ATTACH_MARGIN_MAX then
        margin = AUTO_ATTACH_MARGIN_MAX
    elseif margin < AUTO_ATTACH_MARGIN_MIN then
        margin = AUTO_ATTACH_MARGIN_MIN
    end

    local point, relativeTo, relativePoint, x, y = panel:GetPoint(1)
    if Class.Validate(getmetatable(Scorpio.UI.GetProxyUI(relativeTo)), Scorpio.Secure.UnitFrame) then

        local changed = false
        if point == "TOPLEFT" and relativePoint == "TOPRIGHT" then
            x = margin
            changed = true
        elseif point == "TOPLEFT" and relativePoint == "BOTTOMLEFT" then
            y = margin
            changed = true
        elseif point == "BOTTOMLEFT" and relativePoint == "TOPLEFT" then
            y = margin
            changed = true
        elseif point == "TOPRIGHT" and relativePoint == "TOPLEFT" then
            x = margin
            changed = true
        end

        if changed then
            local location = { Anchor(point, x, y, relativeTo:GetName(), relativePoint) }
            CharSV().Panels[panel.Index].Style.location = location
            Style[panel].location = location
        end
    end

    return
end

__SystemEvent__()
function ASHTOASH_OPEN_MENU(panel, menu)
    local originMargin = getPanelAutoAttachMargin(panel)
    if originMargin then
        tinsert(menu, {
            text        = L["adjust_auto_attach_margin"]:format(panel.Index),
            tiptitle    = L["tips"],
            tiptext     = L["adjust_auto_attach_margin_tips"],
            click       = function()
                if originMargin then
                    local text = Input(L["adjust_auto_attach_margin_input_title"])
                    local margin = tonumber(text) or originMargin
                    setPanelAutoAttachMargin(panel, margin)
                end
            end
        })
    end
end