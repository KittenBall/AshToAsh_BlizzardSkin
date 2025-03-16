Scorpio "AshToAsh.BlizzardSkin.Template" ""

local _Addon = _Addon

UI.Property             {
    name                = "UseParentLevel",
    type                = Boolean,
    require             = Frame,
    default             = false,
    set                 = function(self, val)
        if not val then return end
        local parent = self:GetParent()
        if parent then
            self:SetFrameLevel(parent:GetFrameLevel())
        end
    end
}

-- 选中
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinSelectionHighlightTexture")
class "SelectionHighlightTexture" { Texture }

-- 焦点
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinFocusTexture")
class "FocusTexture" { Texture }

-- 仇恨指示器
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinAggroHighlight")
class "AggroHighlight" { Texture }

-- 载具
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinVehicleIcon")
class "VehicleIcon" { Texture }

-- 团队拾取者
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinMasterLooterIcon")
class "MasterLooterIcon" { Texture }

-- 宠物面板标题
__Sealed__() __ChildProperty__(AshGroupPetPanel, "AshBlzSkinPanelLabel")
class "PetPanelLabel" { FontString }

-- 组合名称
__Sealed__() __ChildProperty__(AshUnitFrame, "CombineNameLabel")
class "CombineNameLabel"(function()
    inherit "Frame"

    __Template__{
        OwnerName   = FontString,
        Name        = FontString
    }
    function __ctor(self)
        self.OwnerName:SetPoint("TOPLEFT", self, "TOPLEFT")
        self.OwnerName:SetPoint("TOPRIGHT", self, "TOPRIGHT")
        self.Name:SetPoint("TOPLEFT", self.OwnerName, "BOTTOMLEFT", 0, 1)
        self.Name:SetPoint("RIGHT", self, "RIGHT")
    end

end)

Style.UpdateSkin(SKIN_NAME,                                             {
    [CombineNameLabel]                                                  = {
        enableMouse                                                     = false,
        enableMouseMotion                                               = false
    }
})

-- 支持OmniCC的Cooldown
__Sealed__() __ChildProperty__(Frame, "OmniCCCooldown")
class "OmniCCCooldown"(function()
    inherit "Cooldown"

    property "HideCountdownNumbers" {
        type        = Boolean,
        default     = false,
        set         = function(self, hideCountdownNumbers)
            self:SetHideCountdownNumbers(hideCountdownNumbers)
            if OmniCC and OmniCC.Cooldown and OmniCC.Cooldown.SetNoCooldownCount then
                OmniCC.Cooldown.SetNoCooldownCount(self, hideCountdownNumbers)
            end
        end
    }

    function SetCooldown(self, ...)
        super.SetCooldown(self, ...)
        if not self.HideCountdownNumbers and OmniCC and OmniCC.Cooldown then
            OmniCC.Cooldown.OnSetCooldown(self, ...)
        end
    end

    function OnSetCooldownDuration(self, ...)
        super.SetCooldown(self, ...)
        if not self.HideCountdownNumbers and OmniCC and OmniCC.Cooldown then
            OmniCC.Cooldown.OnSetCooldownDuration(self, ...)
        end
    end

end)

__Sealed__() struct "LossOfControlData"   {
    { name = "lossOfControlText",   type = NEString },
    { name = "name",                type = NEString },
    { name = "icon",                type = Number   },
    { name = "duration",            type = Number   },
    { name = "expirationTime",      type = Number   }
}

-- 解锁按钮
__Sealed__() __ChildProperty__(AshGroupPanel, "AshBlzSkinUnlockButton")
class "UnlockButton"(function()
    inherit "Button"

    local function OnClick(self)
        if _Addon.UNLOCK_PANELS then
            LockPanels()
        else
            UnlockPanels()
        end
    end

    local function OnEnter(self)
        if not UnitAffectingCombat("player") then
            self:SetAlpha(1)
        end
    end

    local function OnLeave(self)
        self:SetAlpha(0)
    end

    function __ctor(self)
        self:SetAlpha(0)
        self.OnClick = self.OnClick + OnClick
        self.OnEnter = self.OnEnter + OnEnter
        self.OnLeave = self.OnLeave + OnLeave
    end
    
end)

-- EnlargeBuff icon
__Sealed__() class "AshBlzSkinEnlargeBuffIcon" { AshBlzSkinAuraIcon }

-- StatusText
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinStatusText")
class "StatusText" (function()
    inherit "FontString"

    property "HealthTextFormat" {
        type                    = HealthTextFormat,
        default                 = HealthTextFormat.NORMAL
    }

    property "HealthTextStyle"  {
        type                    = HealthTextStyle,
        default                 = HealthTextStyle.NONE
    }

    property "Refresh"          {
        set                     = function(self, unit)
            self:DoRefresh(unit)
        end
    }

    local function formatHealth(self, health)
        if health and health > 0 then
            if self.HealthTextFormat == HealthTextFormat.TEN_THOUSAND then
                return health >= 10000 and ("%.1fW"):format(health/10000) or health
            elseif self.HealthTextFormat == HealthTextFormat.KILO then
                return health >= 1000 and ("%.1fK"):format(health/1000) or health
            else
                return BreakUpLargeNumbers(health)
            end
        end
    end

    function DoRefresh(self, unit)
        local text
        local color = Color.WHITE
        if UnitExists(unit) then
            if not UnitIsConnected(unit) then
                text = PLAYER_OFFLINE
                color = Color.DISABLED
            elseif UnitIsDeadOrGhost(unit) then
                text = DEAD
                color = Color.DISABLED
            elseif self.HealthTextStyle == HealthTextStyle.HEALTH then
                text = formatHealth(self, UnitHealth(unit))
            elseif self.HealthTextStyle == HealthTextStyle.LOSTHEALTH then
                local health = UnitHealth(unit)
                local healthLost = UnitHealthMax(unit) - health
                if healthLost > 0 then
                    text = "-" .. formatHealth(self, healthLost)
                    color = Color.RED
                end
            elseif self.HealthTextStyle == HealthTextStyle.PERCENT then
                local maxHealth = UnitHealthMax(unit)
                if maxHealth > 0 then
                    text = math.ceil(100 * UnitHealth(unit)/maxHealth) .. "%"
                end
            end
        end

        if text then
            self:SetText(text)
            self:SetTextColor(color.r, color.g, color.b)
            self:Show()
        else
            self:Hide()
        end
    end

end)

-- Role icon
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinRoleIcon")
class "RoleIcon"(function()
    inherit "Texture"

    property "Refresh"          {
        set                     = function(self, unit)
            self:DoRefresh(unit)
        end
    }

    function DoRefresh(self, unit)
        local size = self:GetHeight()
	    if UnitInVehicle(unit) and UnitHasVehicleUI(unit) then
	    	self:SetTexture("Interface\\Vehicles\\UI-Vehicles-Raid-Icon")
	    	self:SetTexCoord(0, 1, 0, 1)
	    	self:Show()
	    	self:SetSize(size, size)
	    else
            local raidId = UnitInRaid(unit)
            local role = raidId and select(10, GetRaidRosterInfo(raidId))
            if role then
	    	    self:SetTexture("Interface\\GroupFrame\\UI-Group-"..role.."Icon")
	    	    self:SetTexCoord(0, 1, 0, 1)
	    	    self:Show()
	    	    self:SetSize(size, size)
                return
            end

	    	role = UnitGroupRolesAssigned(unit)
	    	if role == "TANK" or role == "HEALER" or role == "DAMAGER" then
	    		self:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
	    		self:SetTexCoord(GetTexCoordsForOldRoleSmallCircle(role))
	    		self:Show()
	    		self:SetSize(size, size)
                return
            end

	    	self:Hide()
	    	self:SetSize(1, size)
	    end
    end

    function __ctor(self)
        self:SetSize(12, 12)
    end

end)


-- Ready check icon
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinReadyCheckIcon")
class "ReadyCheckIcon"(function()
    inherit "Button"

    property "Update"           {
        set                     = function(self, unit)
            self:UpdateReadyCheck(unit)
        end
    }

    property "Finish"           {
        set                     = function(self)
            self:FinishReadyCheck()
        end
    }

    function FinishReadyCheck(self)
        if self:IsVisible() then
            self.readyCheckDecay = CUF_READY_CHECK_DECAY_TIME
            if self.readyCheckStatus == "waiting" then
                self:SetNormalTexture(READY_CHECK_NOT_READY_TEXTURE)
                self:Show()
            end
        else
            self:UpdateReadyCheck(self.unit)
        end
    end

    function UpdateReadyCheck(self, unit)
        if self.readyCheckDecay and GetReadyCheckTimeLeft() <= 0 then
            return
        end

        if not unit then
            return self:Hide()
        end
        
        self.unit = unit

        local readyCheckStatus = GetReadyCheckStatus(unit)
        self.readyCheckStatus = readyCheckStatus
        if readyCheckStatus == "ready" then
            self:SetNormalTexture(READY_CHECK_READY_TEXTURE)
            self:Show()
        elseif readyCheckStatus == "notready" then
            self:SetNormalTexture(READY_CHECK_NOT_READY_TEXTURE)
            self:Show()
        elseif readyCheckStatus == "waiting" then
            self:SetNormalTexture(READY_CHECK_WAITING_TEXTURE)
            self:Show()
        else
            self:Hide()
        end
    end

    local function OnUpdate(self, elapsed)
        if self.readyCheckDecay then
            if self.readyCheckDecay > 0 then
                self.readyCheckDecay = self.readyCheckDecay - elapsed
            else
                self.readyCheckDecay = nil
                self:UpdateReadyCheck(self.unit)
            end
        end
    end

    function __ctor(self)
        self:EnableMouse(false)
        self.OnUpdate = self.OnUpdate + OnUpdate
    end

end)

TEMPLATE_SKIN_STYLE                                                                     = {

    -- 目标选中边框
    [SelectionHighlightTexture]                                                         = {
        drawLayer                                                                       = "OVERLAY",
        subLevel                                                                        = 1,
        file                                                                            = "Interface\\RaidFrame\\Raid-FrameHighlights",
        texCoords                                                                       = RectType(0.00781250, 0.55468750, 0.28906250, 0.55468750),
        setAllPoints                                                                    = true,
        ignoreParentAlpha                                                               = true,
        visible                                                                         = Wow.UnitIsTarget()
    },

    -- 解锁按钮
    [UnlockButton]                                                                      = {
        normalTexture                                                                   = {
            file                                                                        = "Interface\\Buttons\\LockButton-Locked-Up",
            setAllPoints                                                                = true
        },
        pushedTexture                                                                   = {
            file                                                                        = "Interface\\Buttons\\LockButton-Unlocked-Down",
            setAllPoints                                                                = true
        },
        highlightTexture                                                                = {
            file                                                                        = "Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight",
            alphaMode                                                                   = "ADD",
            setAllPoints                                                                = true
        }
    },

    -- Cooldown
    [OmniCCCooldown]                                                                    = {
        hideCountdownNumbers                                                            = AshBlzSkinApi.AuraHideCountdownNumbers(),
        setAllPoints                                                                    = true,
        reverse                                                                         = true,
        enableMouse                                                                     = false
    }
}

Style.UpdateSkin(SKIN_NAME, TEMPLATE_SKIN_STYLE)

--@retail@
-- CastBar 修改自Scorpio.UI.CooldownStatusBar
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinCastBar")
class "CastBar" (function(_ENV)
    inherit "CooldownStatusBar"

    property "NormalColor"          {
        type                = Color,
        default             = Color.WHITE,
        handler             = function(self)
            self:UpdateStatusBarColor()
        end
    }

    property "NonInterruptColor"    {
        type                = Color,
        set                 = false,
        default             = Color(0.7, 0.7, 0.7)
    }

    property "Interruptible"        {
        type                = Boolean,
        default             = true,
        handler             = function(self)
            self:UpdateStatusBarColor()
        end
    }

    property "Visibility"           {
        type                = Visibility,
        default             = Visibility.SHOW_ONLY_PARTY
    }

    property "Unit"                 {
        type                = String
    }

    function UpdateStatusBarColor(self)
        local color = self.Interruptible and self.NormalColor or self.NonInterruptColor
        self:SetStatusBarColor(color.r, color.g, color.b)
    end

    local function OnUpdate(self, elapsed)
        self.value = self.value + elapsed
        if self.value >= self.maxValue then
            self:Hide()
        else
            local value = self.Reverse and (self.maxValue - self.value) or self.value
            self:SetValue(value)
        end
    end

    local function OnShow(self)
        local unit = self.Unit
        if UnitExists(unit) then
            local target = unit .. "target"
            if UnitExists(target) and UnitCanAttack("player", target) then
                local index = GetRaidTargetIndex(target)
                if index then
                    index           = index - 1
                    local left, right, top, bottom
                    local cIncr     = RAID_TARGET_ICON_DIMENSION / RAID_TARGET_TEXTURE_DIMENSION
                    left            = mod(index , RAID_TARGET_TEXTURE_COLUMNS) * cIncr
                    right           = left + cIncr
                    top             = floor(index / RAID_TARGET_TEXTURE_ROWS) * cIncr
                    bottom          = top + cIncr
                    self.targetMark:SetTexCoord(left, right, top, bottom)
                    return self.targetMark:Show()
                end
            end
        end

        self.targetMark:Hide()
    end

    function SetStatusBarTexture(self, texture)
        super.SetStatusBarTexture(self, texture)
        self.spark:SetPoint("CENTER", texture, "RIGHT", 0, 0)
    end

    function SetCooldown(self, start, duration)
        local visibility = self.Visibility
        if visibility == Visibility.HIDE then
            return
        elseif visibility == Visibility.SHOW_ONLY_PARTY and IsInRaid() then
            return
        end
        
        if duration <= 0 then
            self:Hide()
            return
        end
        self.maxValue  = duration
        self.value = start - GetTime()
        self:SetMinMaxValues(0, duration)
        self:Show()
    end

    __Template__{
        Spark           = Texture,
        TargetMark      = Texture
    }
    function __ctor(self)
        self.value = 0
        self.maxValue = 0
        self.spark = self:GetChild("Spark")
        self.targetMark = self:GetChild("TargetMark")
        self:SetStatusBarColor(self.NormalColor.r, self.NormalColor.g, self.NormalColor.b)
        self.OnUpdate = self.OnUpdate + OnUpdate
        self.OnShow = self.OnShow + OnShow
    end
end)

Style.UpdateSkin(SKIN_NAME,                                                               {
    [CastBar]                                                                           = {
        frameLevel                                                                      = 1,
        statusBarTexture                                                                = {
            file                                                                        = AshBlzSkinApi.CastBarTexture()
        },
        normalColor                                                                     = AshBlzSkinApi.UnitCastBarColor(),
        interruptible                                                                   = Wow.UnitCastInterruptible(),
        cooldown                                                                        = Wow.UnitCastCooldown(),
        reverse                                                                         = Wow.UnitCastChannel(),
        unit                                                                            = Wow.Unit(),

        Spark                                                                           = {
            drawLayer                                                                   = "OVERLAY",
            file                                                                        = "Interface\\CastingBar\\UI-CastingBar-Spark",
            alphaMode                                                                   = "ADD"
        },

        TargetMark                                                                      = {
            file                                                                        = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
            location                                                                    = { Anchor("RIGHT", -2, 0) }
        },

        Label                                                                           = {
            justifyH                                                                    = "CENTER",
            drawLayer                                                                   = "OVERLAY",
            textColor                                                                   = Color.WHITE,
            text                                                                        = Wow.UnitCastName(),
            setAllPoints                                                                = true
        }
    }
})

--@end-retail@

--[===[@non-version-retail@
-- CastBar 修改自Scorpio.UI.CooldownStatusBar
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinCastBar")
class "CastBar" (function(_ENV)
    inherit "CooldownStatusBar"

    property "Visibility"           {
        type                = Visibility,
        default             = Visibility.SHOW_ONLY_PARTY
    }

    property "Unit"                 {
        type                = String
    }

    local function OnUpdate(self, elapsed)
        self.value = self.value + elapsed
        if self.value >= self.maxValue then
            self:Hide()
        else
            local value = self.Reverse and (self.maxValue - self.value) or self.value
            self:SetValue(value)
        end
    end

    function SetStatusBarTexture(self, texture)
        super.SetStatusBarTexture(self, texture)
        self.spark:SetPoint("CENTER", texture, "RIGHT", 0, 0)
    end

    local function OnShow(self)
        local unit = self.Unit
        if UnitExists(unit) then
            local target = unit .. "target"
            if UnitExists(target) and UnitCanAttack("player", target) then
                local index = GetRaidTargetIndex(target)
                if index then
                    index           = index - 1
                    local left, right, top, bottom
                    local cIncr     = RAID_TARGET_ICON_DIMENSION / RAID_TARGET_TEXTURE_DIMENSION
                    left            = mod(index , RAID_TARGET_TEXTURE_COLUMNS) * cIncr
                    right           = left + cIncr
                    top             = floor(index / RAID_TARGET_TEXTURE_ROWS) * cIncr
                    bottom          = top + cIncr
                    self.targetMark:SetTexCoord(left, right, top, bottom)
                    return self.targetMark:Show()
                end
            end
        end

        self.targetMark:Hide()
    end

    function SetCooldown(self, start, duration)
        local visibility = self.Visibility
        if visibility == Visibility.HIDE then
            return
        elseif visibility == Visibility.SHOW_ONLY_PARTY and IsInRaid() then
            return
        end

        if duration <= 0 then
            self:Hide()
            return
        end
        self.maxValue  = duration
        self.value = start - GetTime()
        self:SetMinMaxValues(0, duration)
        self:Show()
    end

    __Template__{
        Spark           = Texture,
        TargetMark      = Texture
    }
    function __ctor(self)
        self.value = 0
        self.maxValue = 0
        self.spark = self:GetChild("Spark")
        self.targetMark = self:GetChild("TargetMark")
        self.OnUpdate = self.OnUpdate + OnUpdate
        self.OnShow = self.OnShow + OnShow
    end
end)

Style.UpdateSkin(SKIN_NAME,                                                               {
    [CastBar]                                                                           = {
        frameLevel                                                                      = 1,
        statusBarTexture                                                                = {
            file                                                                        = AshBlzSkinApi.CastBarTexture()
        },
        statusBarColor                                                                  = AshBlzSkinApi.UnitCastBarColor(),
        cooldown                                                                        = Wow.UnitCastCooldown(),
        reverse                                                                         = Wow.UnitCastChannel(),
        unit                                                                            = Wow.Unit(),

        Spark                                                                           = {
            drawLayer                                                                   = "OVERLAY",
            file                                                                        = "Interface\\CastingBar\\UI-CastingBar-Spark",
            alphaMode                                                                   = "ADD"
        },

        TargetMark                                                                      = {
            file                                                                        = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
            location                                                                    = { Anchor("RIGHT", -2, 0) }
        },

        Label                                                                           = {
            justifyH                                                                    = "CENTER",
            drawLayer                                                                   = "OVERLAY",
            textColor                                                                   = Color.WHITE,
            text                                                                        = Wow.UnitCastName(),
            setAllPoints                                                                = true
        }
    }
})
--@end-non-version-retail@]===]


-- 中间状态图标
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinCenterStatusIcon")
class "CenterStatusIcon"(function()
    inherit "Button"

    property "Refresh"      {
        set                 = function(self, unit)
            self:DoRefresh(unit)
        end
    }

    local function OnEnter(self, motion)
        if self.tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true)
            GameTooltip:Show()
        else
            self:GetParent():OnEnter(motion)
        end
    end
    
    local function OnLeave(self, motion)
        if self.tooltip then
            GameTooltip:Hide()
        else
            self:GetParent():OnLeave(motion)
        end
    end

    --@retail@
    local SummonStatus = _G.Enum.SummonStatus
    function DoRefresh(self, unit)
        local texture = self:GetChild("Texture")
        local border = self:GetChild("Border")
        if UnitInOtherParty(unit) then
            texture:SetTexture("Interface\\LFGFrame\\LFG-Eye")
            texture:SetTexCoord(0.125, 0.25, 0.25, 0.5)
            border:SetTexture("Interface\\Common\\RingBorder")
            border:Show()
            self.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE
            self:Show()
        elseif UnitHasIncomingResurrection(unit) then
            texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            texture:SetTexCoord(0, 1, 0, 1)
            border:Hide()
            self.tooltip = nil
            self:Show()
        elseif C_IncomingSummon.HasIncomingSummon(unit) then
			local status = C_IncomingSummon.IncomingSummonStatus(unit)
            if status == SummonStatus.Pending then
                texture:SetAtlas("Raid-Icon-SummonPending")
                texture:SetTexCoord(0, 1, 0, 1)
                border:Hide()
                self.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_PENDING
                self:Show()
    		elseif( status == SummonStatus.Accepted ) then
                texture:SetAtlas("Raid-Icon-SummonAccepted")
                texture:SetTexCoord(0, 1, 0, 1)
                border:Hide()
                self.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_ACCEPTED
                self:Show()
    		elseif( status == SummonStatus.Declined ) then
                texture:SetAtlas("Raid-Icon-SummonDeclined")
                texture:SetTexCoord(0, 1, 0, 1)
                border:Hide()
                self.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_DECLINED
                self:Show()
    		end
        else
            local phaseReason = UnitPhaseReason(unit)
            if phaseReason then
                texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
                texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
                border:Hide()
                self.tooltip = PartyUtil.GetPhasedReasonString(phaseReason, unit)
                self:Show()
                return
            end

            self:Hide()
        end
    end
    --@end-retail@

    --[===[@non-version-retail@
    function DoRefresh(self, unit)
        local texture = self:GetChild("Texture")
        local border = self:GetChild("Border")
        if UnitInOtherParty(unit) then
            texture:SetTexture("Interface\\LFGFrame\\LFG-Eye")
            texture:SetTexCoord(0.125, 0.25, 0.25, 0.5)
            texture:Show()
            border:SetTexture("Interface\\Common\\RingBorder")
            border:Show()
            self.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE
            self:Show()
        elseif UnitHasIncomingResurrection(unit) then
            texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            texture:SetTexCoord(0, 1, 0, 1)
            texture:Show()
            border:Hide()
            self.tooltip = nil
            self:Show()
        elseif not UnitInPhase(unit) then
            texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
            texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
            texture:Show()
            border:Hide()
            self.tooltip = PARTY_PHASED_MESSAGE
            self:Show()
        else
            self:Hide()
        end
    end
    --@end-non-version-retail@]===]

    __Template__{
        Border      = Texture,
        Texture     = Texture
    }
    function __ctor(self)
        self.OnEnter = self.OnEnter + OnEnter
        self.OnLeave = self.OnLeave + OnLeave
    end
end)

Style.UpdateSkin(SKIN_NAME,                                                               {
    [CenterStatusIcon]                                                                  = {
        enableMouseMotion                                                               = true,
        enableMouseClicks                                                               = false,

        Texture                                                                         = {
            drawLayer                                                                   = "ARTWORK",
            setAllPoints                                                                = true
        },

        Border                                                                          = {
            drawLayer                                                                   = "BORDER",
            setAllPoints                                                                = true
        }
    }
})