Scorpio "AshToAsh.BlizzardSkin.Template.Retail" ""

if not Scorpio.IsRetail then return end

-- 中间状态图标
__Sealed__() __ChildProperty__(Scorpio.Secure.UnitFrame, "AshBlzSkinCenterStatusIcon")
class "CenterStatusIcon"(function()
    inherit "Button"

    property "Unit" { 
        type        = String,
        handler     = function(self, unit)
            self:Update()
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

    function Update(self)
        local unit = self.Unit
        if not unit then return end
        local texture = self:GetChild("Texture")
        local border = self:GetChild("Border")
        if UnitInOtherParty(unit) then
            texture:SetTexture("Interface\\LFGFrame\\LFG-Eye")
            texture:SetTexCoord(0.125, 0.25, 0.25, 0.5)
            border:SetTexture("Interface\\Common\\RingBorder")
            border:Show()
            self.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE
        elseif UnitHasIncomingResurrection(unit) then
            texture:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
            texture:SetTexCoord(0, 1, 0, 1)
            border:Hide()
            self.tooltip = nil
        elseif C_IncomingSummon.HasIncomingSummon(unit) then
            if status == _G.Enum.SummonStatus.Pending then
                texture:SetAltas("Raid-Icon-SummonPending")
                texture:SetTexCoord(0, 1, 0, 1)
                border:Hide()
                self.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_PENDING
    		elseif( status == _G.Enum.SummonStatus.Accepted ) then
                texture:SetAltas("Raid-Icon-SummonAccepted")
                texture:SetTexCoord(0, 1, 0, 1)
                border:Hide()
                self.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_ACCEPTED
    		elseif( status == _G.Enum.SummonStatus.Declined ) then
                texture:SetAltas("Raid-Icon-SummonDeclined")
                texture:SetTexCoord(0, 1, 0, 1)
                border:Hide()
                self.tooltip = INCOMING_SUMMON_TOOLTIP_SUMMON_DECLINED
    		end
        else
            local phaseReason = UnitPhaseReason(unit)
            if phaseReason then
                texture:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
                texture:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
                border:Hide()
                self.tooltip = PartyUtil.GetPhasedReasonString(phaseReason, unit)
            end
        end
    end

    local function OnShow(self)
        self:Update()
    end

    __Template__{
        Border      = Texture,
        Texture     = Texture
    }
    function __ctor(self)
        self.OnEnter = self.OnEnter + OnEnter
        self.OnLeave = self.OnLeave + OnLeave
        self.OnShow  = self.OnShow + OnShow
    end
end)

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
        Spark           = Texture
    }
    function __ctor(self)
        self.value = 0
        self.maxValue = 0
        self.spark = self:GetChild("Spark")
        self:SetStatusBarColor(self.NormalColor)
        self.OnUpdate = self.OnUpdate + OnUpdate
    end
end)

Style.UpdateSkin(SKIN_NAME,{
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
    },

    -- 施法条
    [CastBar]                                                                           = {
        frameLevel                                                                      = 1,
        statusBarTexture                                                                = {
            file                                                                        = AshBlzSkinApi.CastBarTexture()
        },
        normalColor                                                                     = AshBlzSkinApi.UnitCastBarColor(),
        interruptible                                                                   = Wow.UnitCastInterruptible(),
        cooldown                                                                        = Wow.UnitCastCooldown(),
        reverse                                                                         = Wow.UnitCastChannel(),

        Spark                                                                           = {
            drawLayer                                                                   = "OVERLAY",
            file                                                                        = "Interface\\CastingBar\\UI-CastingBar-Spark",
            alphaMode                                                                   = "ADD"
        },

        Label                                                                           = {
            justifyH                                                                    = "CENTER",
            drawLayer                                                                   = "OVERLAY",
            textColor                                                                   = Color.WHITE,
            text                                                                        = Wow.UnitCastName(),
            setAllPoints                                                                = true
        }
    },
})