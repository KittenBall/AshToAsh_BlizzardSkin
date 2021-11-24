Scorpio "AshToAsh.BlizzardSkin.Active" ""

-- 能量条高度
POWERBAR_HEIGHT     = 9

local shareColor    = ColorType(0, 0, 0, 1)
local shareSize     = Size(1, 1)

local function getDynamicFontHeight(frameHeight, fontSize, minScale, maxScale)
    local scale = frameHeight / 48
    local minHeight = fontSize * (minScale or 1)
    local maxHeight = fontSize * (maxScale or 1)

    if minHeight > maxHeight then
        minHeight = maxHeight
    end

    fontSize = fontSize * scale

    if fontSize > maxHeight then
        fontSize = maxHeight
    elseif fontSize < minHeight then
        fontSize = minHeight
    end
    return fontSize
end

__Static__() __AutoCache__()
function AshBlzSkinApi.OnUnitFrameSizeChanged()
    return Wow.FromFrameSize(UnitFrame)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.RelocationUnitFrameBottomIcon()
    return AshBlzSkinApi.OnUnitFrameSizeChanged():Map(function(w, h)
        return { Anchor("BOTTOM", 0, h/3-4) }
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.ResizeUnitFrameIcon(size)
    return AshBlzSkinApi.OnUnitFrameSizeChanged():Map(function(w, h)
        local componentScale = min(w / 72, h / 36)
        return Size((size or 15) * componentScale, (size or 15) * componentScale)
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.ResizeOnUnitFrameChanged(size)
    return AshBlzSkinApi.OnUnitFrameSizeChanged():Map(function(w, h)
        local componentScale = min(w / 72, h / 36)
        return (size or 10) * componentScale
    end)
end

-------------------------------------------------
-- Dynamic Style
-------------------------------------------------

-------------------------------------------------
-- Health Label
-------------------------------------------------
SHARE_HEALTHLABEL_SKIN                                                                       = {
    location                                                                                 = {
        Anchor("CENTER"),
        Anchor("TOP", 0, -2, "NameLabel", "BOTTOM")
    }
}

local function formatHealth(health)
    if health and health > 0 then
        if DB().Appearance.HealthBar.HealthText.TextFormat == HealthTextFormat.TEN_THOUSAND then
            return health >= 10000 and ("%.1fW"):format(health/10000) or health
        elseif DB().Appearance.HealthBar.HealthText.TextFormat == HealthTextFormat.KILO then
            return health >= 1000 and ("%.1fK"):format(health/1000) or health
        else
            return BreakUpLargeNumbers(health)
        end
    end
end

__Static__() __AutoCache__()
function AshBlzSkinApi.HealthLabelSkin()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        local healthTextStyle = DB().Appearance.HealthBar.HealthText.Style
        if healthTextStyle == HealthTextStyle.HEALTH then
            SHARE_HEALTHLABEL_SKIN.text  = Wow.UnitHealthFrequent():Map(formatHealth)
        elseif healthTextStyle == HealthTextStyle.LOSTHEALTH then
            SHARE_HEALTHLABEL_SKIN.text  = Wow.UnitHealthLostFrequent():Map(formatHealth):Map(function(health) return health and ("-" .. health) end)
        elseif healthTextStyle == HealthTextStyle.PERCENT then
            SHARE_HEALTHLABEL_SKIN.text  = Wow.UnitHealthPercentFrequent():Map(function(percent)
                return percent > 0 and percent.."%" or nil
            end)
        else
            return nil
        end
        
        SHARE_HEALTHLABEL_SKIN.textColor = (healthTextStyle == HealthTextStyle.LOSTHEALTH and Color.RED or Color.WHITE)
        
        if DB().Appearance.HealthBar.HealthText.ScaleWithFrame then
            SHARE_HEALTHLABEL_SKIN.Font = Wow.FromFrameSize(UnitFrame):Map(function(w, h)
                local fontType = {}
                fontType.font = GetLibSharedMediaFont(DB().Appearance.HealthBar.HealthText.Font) or HealthLabelFont
                fontType.outline = DB().Appearance.HealthBar.HealthText.FontOutline
                fontType.monochrome = DB().Appearance.HealthBar.HealthText.FontMonochrome
                fontType.height = getDynamicFontHeight(h, DB().Appearance.HealthBar.HealthText.FontSize, 0.6)
                return fontType
            end)
        else
            local fontType = {}
            fontType.font = GetLibSharedMediaFont(DB().Appearance.HealthBar.HealthText.Font) or HealthLabelFont
            fontType.outline = DB().Appearance.HealthBar.HealthText.FontOutline
            fontType.monochrome = DB().Appearance.HealthBar.HealthText.FontMonochrome
            fontType.height = DB().Appearance.HealthBar.HealthText.FontSize
            SHARE_HEALTHLABEL_SKIN.Font = fontType
        end

        return SHARE_HEALTHLABEL_SKIN
    end)
end

-------------------------------------------------
-- Panel Label
-------------------------------------------------
GROUP_PANEL_LABEL_SKIN                                                                       = {
    fontObject                                                                               = AshBlzSkinApi.UnitPanelOrientation():Map(function(orientation)
        if orientation == Orientation.HORIZONTAL then
            return GameFontNormalTiny
        else
            return GameFontNormalSmall
        end
    end),
    justifyH                                                                                 = "CENTER",
    text                                                                                     = AshBlzSkinApi.UnitPanelLabel(),
    visible                                                                                  = AshBlzSkinApi.UnitPanelLabelVisible(),
    location                                                                                 = AshBlzSkinApi.UnitPanelOrientation():Map(function(orientation)
        if orientation == Orientation.HORIZONTAL then
            return { Anchor("RIGHT", 0, 0, nil, "LEFT") }
        else
            return { Anchor("BOTTOM", 0, 1, nil, "TOP") }
        end
    end),
}

__Static__() __AutoCache__()
function AshBlzSkinApi.PanelLableSkin()
    return Wow.FromEvent("ASHTOASH_BLIZZARD_SKIN_CONFIG_CHANGED", "ASHTOASH_CONFIG_CHANGED"):Map(function()
        return DB().Appearance.DisplayPanelLabel and GROUP_PANEL_LABEL_SKIN or nil
    end)
end

-- 宠物面板标题
GROUP_PET_PANEL_LABEL_SKIN                                                                  = {
    fontObject                                                                              = AshBlzSkinApi.UnitPanelOrientation():Map(function(orientation)
        if orientation == Orientation.HORIZONTAL then
            return GameFontNormalTiny
        else
            return GameFontNormalSmall
        end
    end),
    justifyH                                                                                = "CENTER",
    text                                                                                    = AshBlzSkinApi.UnitPetPanelLabel(),
    visible                                                                                 = AshBlzSkinApi.UnitPetPanelLabelVisible(),
    location                                                                                = AshBlzSkinApi.UnitPetPanelOrientation():Map(function(orientation)
        if orientation == Orientation.HORIZONTAL then
            return { Anchor("RIGHT", 0, 0, nil, "LEFT") }
        else
            return { Anchor("BOTTOM", 0, 1, nil, "TOP") }
        end
    end),
}

__Static__() __AutoCache__()
function AshBlzSkinApi.PetPanelLableSkin()
    return Wow.FromEvent("ASHTOASH_BLIZZARD_SKIN_CONFIG_CHANGED", "ASHTOASH_CONFIG_CHANGED"):Map(function()
        return DB().Appearance.DisplayPetPanelLabel and GROUP_PET_PANEL_LABEL_SKIN or nil
    end)
end


-------------------------------------------------
-- Power Bar
-------------------------------------------------

SHARE_POWERBAR_SKIN                                                                         = {
    frameStrata                                                                             = "MEDIUM",
    useParentLevel                                                                          = true,
    statusBarTexture                                                                        = {
        file                                                                                = AshBlzSkinApi.PowerBarTexture(),
        drawLayer                                                                           = "BORDER"
    },
    location                                                                                = {
        Anchor("TOPLEFT", 0, 0, "PredictionHealthBar", "BOTTOMLEFT"),
        Anchor("BOTTOMRIGHT", -1, 1)
    },

    BackgroundTexture                                                                       = {
        file                                                                                = AshBlzSkinApi.PowerBarBackground(),
        setAllPoints                                                                        = true,
        subLevel                                                                            = 2,
        drawLayer                                                                           = "BACKGROUND"
    }
}


-- 玩家能量条
POWER_BAR_SKIN                                                                              = {
    SHARE_POWERBAR_SKIN,

    value                                                                                   = AshBlzSkinApi.UnitPower(),
    minMaxValues                                                                            = AshBlzSkinApi.UnitPowerMax(),
    statusBarColor                                                                          = AshBlzSkinApi.UnitPowerColor()
}

__Static__() __AutoCache__()
function AshBlzSkinApi.PowerBarSkin()
    return AshBlzSkinApi.PowerBarVisible():Map(function(visible)
        return visible and POWER_BAR_SKIN or nil
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.PetPowerBarSkin()
    return AshBlzSkinApi.PowerBarVisible():Map(function(visible)
        return visible and SHARE_POWERBAR_SKIN or nil
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.CastBarVisibilityChanged()
    return AshBlzSkinApi.PowerBarVisible():Map(function(visible)
        return visible and DB().Appearance.CastBar.Visibility or Visibility.HIDE
    end)
end

-------------------------------------------------
-- CastBar
-------------------------------------------------

__Static__() __AutoCache__()
function AshBlzSkinApi.CastBarLabelFontStyle()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
            local fontType = {}
            fontType.font = GetLibSharedMediaFont(DB().Appearance.CastBar.Font) or CastBarLabelFont
            fontType.outline = DB().Appearance.CastBar.FontOutline
            fontType.monochrome = DB().Appearance.CastBar.FontMonochrome
            fontType.height = DB().Appearance.CastBar.FontSize
        return fontType
    end)
end

SHARE_CASTBAR_SKIN                                                                          = {
    frameStrata                                                                             = "MEDIUM",
    useParentLevel                                                                          = true,
    height                                                                                  = POWERBAR_HEIGHT - 1,
    location                                                                                = {
        Anchor("TOPLEFT", 0, 0, "PowerBar", "TOPLEFT"),
        Anchor("BOTTOMRIGHT", 0, 0, "PowerBar", "BOTTOMRIGHT") 
    },
    visibility                                                                              = AshBlzSkinApi.CastBarVisibilityChanged(),

    Spark                                                                                   = {
        size                                                                                = Size(24, 24),
    },

    Label                                                                                   = {
        font                                                                                = AshBlzSkinApi.CastBarLabelFontStyle()
    }
}

__Static__() __AutoCache__()
function AshBlzSkinApi.CastBarSkin()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        return (DB().Appearance.PowerBar.Visibility == Visibility.SHOW_ALWAYS and DB().Appearance.CastBar.Visibility) and SHARE_CASTBAR_SKIN or nil
    end)
end

-------------------------------------------------
-- Aggro
-------------------------------------------------
AGGRO_SKIN                                                                                  = {
    drawLayer                                                                               = "ARTWORK",
    subLevel                                                                                = 3,
    file                                                                                    = "Interface\\RaidFrame\\Raid-FrameHighlights",
    texCoords                                                                               = RectType(0.00781250, 0.55468750, 0.00781250, 0.27343750),
    setAllPoints                                                                            = true,
    visible                                                                                 = Wow.UnitThreatLevel():Map("l=> l>0"),
    vertexColor                                                                             = Wow.UnitThreatLevel():Map(function(level)
        shareColor.r, shareColor.g, shareColor.b, shareColor.a = GetThreatStatusColor(level)
        return shareColor
    end)
}

-- 宠物仇恨指示器
PET_AGGRO_SKIN                                                                              = {
    AGGRO_SKIN,

    visible                                                                                 = AshBlzSkinApi.UnitPetThreatLevel():Map("l=> l>0"),
    vertexColor                                                                             = AshBlzSkinApi.UnitPetThreatLevel():Map(function(level)
        shareColor.r, shareColor.g, shareColor.b, shareColor.a = GetThreatStatusColor(level)
        return shareColor
    end)
}

__Static__() __AutoCache__()
function AshBlzSkinApi.AggroSkin()
    return  AshBlzSkinApi.OnConfigChanged():Map(function()
        return DB().Appearance.DisplayAggroHighlight and AGGRO_SKIN or nil
    end)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.PetAggroSkin()
    return  AshBlzSkinApi.OnConfigChanged():Map(function()
        return DB().Appearance.DisplayAggroHighlight and PET_AGGRO_SKIN or nil
    end)
end

-------------------------------------------------
-- Name
-------------------------------------------------

SHARE_NAMELABEL_SKIN                                                                        = {
    drawLayer                                                                               = "ARTWORK",
    wordWrap                                                                                = false,
    justifyH                                                                                = "LEFT",
    textColor                                                                               = AshBlzSkinApi.UnitNameColor()
}

-- 名字指示器
NAMELABEL_SKIN                                                                              = {
    SHARE_NAMELABEL_SKIN,

    text                                                                                    = AshBlzSkinApi.UnitName(),
    location                                                                                = {
        Anchor("TOPLEFT", 0, -1, "RoleIcon", "TOPRIGHT"), 
        Anchor("TOPRIGHT", -3, -3) 
    }
}

__Static__() __AutoCache__()
function AshBlzSkinApi.NameSkin()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
            if DB().Appearance.Name.ScaleWithFrame then
                NAMELABEL_SKIN.Font = Wow.FromFrameSize(UnitFrame):Map(function(w, h)
                    local fontType = {}
                    fontType.font = GetLibSharedMediaFont(DB().Appearance.Name.Font) or NameFont
                    fontType.outline = DB().Appearance.Name.FontOutline
                    fontType.monochrome = DB().Appearance.Name.FontMonochrome
                    fontType.height = getDynamicFontHeight(h, DB().Appearance.Name.FontSize, 0.6)
                    return fontType
                    end)
            else
                local fontType = {}
                fontType.font = GetLibSharedMediaFont(DB().Appearance.Name.Font) or HealthLabelFont
                fontType.outline = DB().Appearance.Name.FontOutline
                fontType.monochrome = DB().Appearance.Name.FontMonochrome
                fontType.height = DB().Appearance.Name.FontSize
                NAMELABEL_SKIN.Font = fontType
            end
        return NAMELABEL_SKIN
    end)
end

-------------------------------------------------
-- Focus
-------------------------------------------------

FOCUS_SKIN                                                                                  = {
    file                                                                                    = "Interface\\AddOns\\AshToAsh_BlizzardSkin\\Media\\indicator_focus",
    setAllPoints                                                                            = true,
    vertexColor                                                                             = Color(0.9, 0.9, 0.9),
    texCoords                                                                               = RectType(0.1, 0.9, 0.1, 0.9),
    visible                                                                                 = AshBlzSkinApi.UnitIsFocus()
}

__Static__() __AutoCache__()
function AshBlzSkinApi.FocusSkin()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        return DB().Appearance.DisplayFocusHighlight and FOCUS_SKIN or nil
    end)
end


-------------------------------------------------
-- Debuff
-------------------------------------------------
local DebuffPanelNoBossAuraLocation = { Anchor("BOTTOMLEFT", 3, 1.5, "PredictionHealthBar", "BOTTOMLEFT") }
local DebuffPanelBossAuraLocation   = { Anchor("BOTTOMLEFT", 1, 0, "AshBlzSkinBossDebuffIcon", "BOTTOMRIGHT") }
SHARE_DEBUFFPANEL_SKIN                                                                      = {
    elementType                                                                             = AshBlzSkinDebuffIcon,
    orientation                                                                             = Orientation.HORIZONTAL,
    leftToRight                                                                             = true,
    topToBottom                                                                             = false,
    rowCount                                                                                = 1,
    columnCount                                                                             = AshBlzSkinApi.UnitBossAura():Map(function(val) return val and 1 or 3 end),
    marginLeft                                                                              = 1,
    hSpacing                                                                                = 0.5,
    vSpacing                                                                                = 1,
    location                                                                                = AshBlzSkinApi.UnitBossAura():Map(function(val)
        return val and DebuffPanelBossAuraLocation or DebuffPanelNoBossAuraLocation
    end),
    displayOnlyDispellableDebuffs                                                           = AshBlzSkinApi.DisplayOnlyDispellableDebuffs(),

    customFilter                                                                            = function(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID)
        return not (_AuraBlackList[spellID] or _EnlargeDebuffList[spellID])
    end,
}

__Static__() __AutoCache__()
function AshBlzSkinApi.DebuffPanelSkin()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        SHARE_DEBUFFPANEL_SKIN.elementWidth = AshBlzSkinApi.ResizeOnUnitFrameChanged(DB().Appearance.Aura.AuraSize)
        SHARE_DEBUFFPANEL_SKIN.elementHeight = AshBlzSkinApi.ResizeOnUnitFrameChanged(DB().Appearance.Aura.AuraSize)
        return SHARE_DEBUFFPANEL_SKIN
    end)
end

-------------------------------------------------
-- Buff
-------------------------------------------------
SHARE_BUFFPANEL_SKIN                                                                        = {
    elementType                                                                             = AshBlzSkinBuffIcon,
    orientation                                                                             = Orientation.HORIZONTAL,
    marginRight                                                                             = 3,
    rowCount                                                                                = 1,
    columnCount                                                                             = 3,
    hSpacing                                                                                = 0,
    leftToRight                                                                             = false,
    topToBottom                                                                             = false,
    location                                                                                = {
        Anchor("BOTTOMRIGHT", 0, 1.5, "PredictionHealthBar", "BOTTOMRIGHT") 
    },
        
    customFilter                                                                            = function(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID) 
        return not _AuraBlackList[spellID] and not (_ClassBuffList[name] or _ClassBuffList[spellID]) and not EnlargeBuffList[spellID]
    end,
}

__Static__() __AutoCache__()
function AshBlzSkinApi.BuffPanelSkin()
    return AshBlzSkinApi.OnConfigChanged():Map(function()
        SHARE_BUFFPANEL_SKIN.elementWidth = AshBlzSkinApi.ResizeOnUnitFrameChanged(DB().Appearance.Aura.AuraSize)
        SHARE_BUFFPANEL_SKIN.elementHeight = AshBlzSkinApi.ResizeOnUnitFrameChanged(DB().Appearance.Aura.AuraSize)
        return SHARE_BUFFPANEL_SKIN
    end)
end

-------------------------------------------------
-- Master loot
-------------------------------------------------

MASTER_LOOTER_SKIN                                                                          = {
    location                                                                                = {
        Anchor("RIGHT", -1, 0, "RaidRosterIcon", "LEFT")
    },
    size                                                                                    = Size(11, 11),
    file                                                                                    = "Interface\\GroupFrame\\UI-Group-MasterLooter",
    visible                                                                                 = AshBlzSkinApi.UnitIsMasterLooter()
}

__Static__() __AutoCache__()
function AshBlzSkinApi.MasterLooterSkin()
    return Observable.Just(not Scorpio.IsRetail):Map(function(display)
        if display then return MASTER_LOOTER_SKIN end
    end)
end

-------------------------------------------------
-- Dispellable debuff
-------------------------------------------------

DISPELLABLE_DEBUFF_SKIN                                                                     = {
    drawLayer                                                                               = "BORDER",
    subLevel                                                                                = 2,
    location                                                                                = {
        Anchor("TOPLEFT", 0, 0, "$parent.statusBarTexture", "TOPLEFT"),
        Anchor("BOTTOMRIGHT", 0, 0, "$parent.statusBarTexture", "BOTTOMRIGHT")
    },
    ignoreParentAlpha                                                                       = true,
    file                                                                                    = AshBlzSkinApi.HealthBarTexture(),
    vertexColor                                                                             = AshBlzSkinApi.UnitDebuffCanDispellColor(),
    visible                                                                                 = AshBlzSkinApi.UnitDebuffCanDispell(),

    AnimationGroup                                                                          = {
        playing                                                                             = true,
        looping                                                                             = "REPEAT",

        Alpha1                                                                              = {
            smoothing                                                                       = "OUT",
            order                                                                           = 1,
            duration                                                                        = 0.5,
            fromAlpha                                                                       = 0,
            toAlpha                                                                         = 1
        },
        Alpha2                                                                              = {
            smoothing                                                                       = "IN",
            order                                                                           = 2,
            duration                                                                        = 0.5,
            fromAlpha                                                                       = 1,
            toAlpha                                                                         = 0
        }
    }
}

__Static__() __AutoCache__()
function AshBlzSkinApi.DispellableDebuffSkin()
    return AshBlzSkinApi.DisplayDispellableDebuffHighlight():Map(function(display)
        return display and DISPELLABLE_DEBUFF_SKIN or nil
    end)
end

-------------------------------------------------
-- Dispellable debuff pixel glow
-------------------------------------------------

PIXELGLOW_SKIN                                                                              = {
    visible                                                                                 = AshBlzSkinApi.UnitDebuffCanDispell()
}

__Static__() __AutoCache__()
function AshBlzSkinApi.DispellableDebuffPixelGlowSkin()
    return AshBlzSkinApi.DisplayDispellableDebuffHighlight():Map(function(display)
        return display and PIXELGLOW_SKIN or nil
    end)
end

-------------------------------------------------
-- Share Skin
-------------------------------------------------

-- Enlarge buff
SHARE_ENLARGEBUFFICON_SKIN                                                                 = {
    width                                                                                   = AshBlzSkinApi.ResizeOnUnitFrameChanged(15),
    height                                                                                  = AshBlzSkinApi.ResizeOnUnitFrameChanged(15),
    location                                                                                = {
        Anchor("TOPRIGHT", -3, -3, "PredictionHealthBar", "TOPRIGHT")
    },
}

-- Enlarge debuff
SHARE_ENLARGEDEBUFFICON_SKIN                                                                = {
    width                                                                                   = AshBlzSkinApi.ResizeOnUnitFrameChanged(15),
    height                                                                                  = AshBlzSkinApi.ResizeOnUnitFrameChanged(15),
    location                                                                                = {
        Anchor("TOPLEFT", 3, -3, "PredictionHealthBar", "TOPLEFT")
    }
}

-- Dispell debuff
SHARE_DISPELLDEBUFFPANEL_SKIN                                                               = {
    elementType                                                                             = AshBlzSkinDispellIcon,
    leftToRight                                                                             = false,
    topToBottom                                                                             = false,
    rowCount                                                                                = 1,
    columnCount                                                                             = 4,
    hSpacing                                                                                = 1.5,
    vSpacing                                                                                = 1,
    marginRight                                                                             = 3,
    marginTop                                                                               = 4,
    elementWidth                                                                            = AshBlzSkinApi.ResizeOnUnitFrameChanged(9),
    elementHeight                                                                           = AshBlzSkinApi.ResizeOnUnitFrameChanged(9),
    location                                                                                = {
        Anchor("TOPRIGHT", 0, 0, "PredictionHealthBar", "TOPRIGHT")
    }
}

-- Boss debuff
SHARE_BOSSDEBUFFICON_SKIN                                                                   = {
    width                                                                                   = AshBlzSkinApi.ResizeOnUnitFrameChanged(15),
    height                                                                                  = AshBlzSkinApi.ResizeOnUnitFrameChanged(15),
    location                                                                                = {
        Anchor("BOTTOMLEFT", 3, 1.5, "PredictionHealthBar", "BOTTOMLEFT")
    }
}

-- 标记
SHARE_RAIDTARGET_SKIN                                                                       = {
    drawLayer                                                                               = "OVERLAY",
    location                                                                                = {
        Anchor("TOPRIGHT", -3, -2)
    },
    size                                                                                    = AshBlzSkinApi.ResizeUnitFrameIcon(14)
}

-- 血条
SHARE_HEALTHBAR_SKIN                                                                        = {
    frameStrata                                                                             = "MEDIUM",
    useParentLevel                                                                          = true,
    statusBarTexture                                                                        = {
        file                                                                                = AshBlzSkinApi.HealthBarTexture(),
        drawLayer                                                                           = "BORDER"
    },
    location                                                                                = AshBlzSkinApi.PowerBarVisible():Map(function(powerBarVisible)
        if powerBarVisible then
            return { Anchor("TOPLEFT", 1, -1), Anchor("BOTTOMRIGHT", -1, POWERBAR_HEIGHT) }
        else
            return { Anchor("TOPLEFT", 1, -1), Anchor("BOTTOMRIGHT", -1, 1) }
        end
    end),

    -- 拥有驱散debuff的能力
    IconTexture                                                                             = AshBlzSkinApi.DispellableDebuffSkin()
}

-------------------------------------------------
-- Skin
-------------------------------------------------

SKIN_STYLE =                                                                                {
    -- 单位面板
    [AshGroupPanel]                                                                         = {
        clampedToScreen                                                                     = true,

        Label                                                                               = AshBlzSkinApi.PanelLableSkin(),

        -- 解锁按钮
        AshBlzSkinUnlockButton                                                              = {
            size                                                                            = Size(24, 24),
            visible                                                                         = AshBlzSkinApi.UnitPanelVisible(),
            location                                                                        = {
                Anchor("BOTTOMLEFT", -2, -1, nil, "TOPLEFT")
            }
        }
    },

    -- 宠物面板
    [AshGroupPetPanel]                                                                      = {
        clampedToScreen                                                                     = true,

        Label                                                                               = AshBlzSkinApi.PetPanelLableSkin()
    },

    [AshUnitFrame]                                                                          = {
        frameStrata                                                                         = "MEDIUM",
        alpha                                                                               = AshBlzSkinApi.UnitInRange():Map('v=>v and 1 or 0.55'),
        auraEngine                                                                          = AshBlzSkinApi.AuraEngine(),

        -- 可驱散debuff高亮
        PixelGlow                                                                           = AshBlzSkinApi.DispellableDebuffPixelGlowSkin(),

        BackgroundTexture                                                                   = {
            file                                                                            = AshBlzSkinApi.UnitFrameBackground(),
            texCoords                                                                       = RectType(0, 1, 0, 0.53125),
            setAllPoints                                                                    = true,
            ignoreParentAlpha                                                               = true,
            drawLayer                                                                       = "BACKGROUND"
        },

        -- 焦点
        AshBlzSkinFocusTexture                                                              = AshBlzSkinApi.FocusSkin(),

        -- 选中
        AshBlzSkinSelectionHighlightTexture                                                 = {},

        -- 仇恨指示器
        AshBlzSkinAggroHighlight                                                            = AshBlzSkinApi.AggroSkin(),

        -- 名字
        NameLabel                                                                           = AshBlzSkinApi.NameSkin(),

        -- 血量文本
        HealthLabel                                                                         = AshBlzSkinApi.HealthLabelSkin(),

        -- 死亡图标
        AshBlzSkinDeadIcon                                                                  = {
            size                                                                            = AshBlzSkinApi.ResizeUnitFrameIcon(),
            location                                                                        = AshBlzSkinApi.RelocationUnitFrameBottomIcon(),
        },

        -- 角色职责图标
        RoleIcon                                                                            = {
            location                                                                        = {
                Anchor("TOPLEFT", 3, -2)
            },
            size                                                                            = Wow.UnitRoleVisible():Map(function(val)
                if val then
                    shareSize.width, shareSize.height = 12, 12
                else
                    shareSize.width, shareSize.height = 1, 1
                end
                return shareSize
            end),
            visible                                                                         = true
        },

        -- 载具图标
        AshBlzSkinVehicleIcon                                                               = {
            location                                                                        = {
                Anchor("TOPLEFT", 0, -1, "RoleIcon", "BOTTOMLEFT")
            },
            size                                                                            = Size(12, 12),
            file                                                                            = "Interface\\Vehicles\\UI-Vehicles-Raid-Icon",
            texCoords                                                                       = RectType(0, 1, 0, 1),
            visible                                                                         = AshBlzSkinApi.UnitVehicleVisible()
        },

        -- 队长图标
        LeaderIcon                                                                          = {
            location                                                                        = {
                Anchor("TOPRIGHT", -3, -2)
            },
            file                                                                            = AshBlzSkinApi.UnitIsLeaderOrAssistantIcon(),
            visible                                                                         = true,
            drawLayer                                                                       = "ARTWORK",
            subLevel                                                                        = 2,
            size                                                                            = AshBlzSkinApi.UnitIsLeaderOrAssistant():Map(function(isLeader)
                if isLeader then
                    shareSize.width, shareSize.height = 11, 11
                else
                    shareSize.width, shareSize.height = 1, 11
                end
                return shareSize
            end)
        },

        -- 主坦克、主助理
        RaidRosterIcon                                                                      = {
            location                                                                        = {
                Anchor("RIGHT", -1, 0, "LeaderIcon", "LEFT")
            },
            drawLayer                                                                       = "ARTWORK",
            subLevel                                                                        = 2,
            size                                                                            = Wow.UnitGroupRoster():Map(function(assign)
                if not assign or assign == "NONE" then
                    shareSize.width, shareSize.height = 1, 11
                else
                    shareSize.width, shareSize.height = 11, 11
                end
                return shareSize
            end),
        },
        
        -- 团队拾取者
        AshBlzSkinMasterLooterIcon                                                          = AshBlzSkinApi.MasterLooterSkin(),

        -- 标记图标
        RaidTargetIcon                                                                      = SHARE_RAIDTARGET_SKIN,

        -- 离线图标
        DisconnectIcon                                                                      = {
            location                                                                        = AshBlzSkinApi.RelocationUnitFrameBottomIcon(),
            size                                                                            = AshBlzSkinApi.ResizeUnitFrameIcon()
        },

        -- 准备就绪
        ReadyCheckIcon                                                                      = {
            drawLayer                                                                       = "OVERLAY",
            location                                                                        = AshBlzSkinApi.RelocationUnitFrameBottomIcon(),
            size                                                                            = AshBlzSkinApi.ResizeUnitFrameIcon()
        },

        -- 中间状态图标
        AshBlzSkinCenterStatusIcon                                                          = {
            location                                                                        = AshBlzSkinApi.OnUnitFrameSizeChanged():Map(function(w, h)
                return { Anchor("CENTER", 0, h / 3 + 2, nil, "BOTTOM") }
            end),
            size                                                                            = AshBlzSkinApi.ResizeUnitFrameIcon(22),
            visible                                                                         = AshBlzSkinApi.UnitCenterStatusIconVisible(),
            unit                                                                            = Wow.Unit()
        },

        -- 血条
        PredictionHealthBar                                                                 = {
            SHARE_HEALTHBAR_SKIN,

            statusBarColor                                                                  = AshBlzSkinApi.UnitColor(),
        },

        -- 能量条
        PowerBar                                                                            = AshBlzSkinApi.PowerBarSkin(),

        -- 施法条
        AshBlzSkinCastBar                                                                   = AshBlzSkinApi.CastBarSkin(),

        AshBlzSkinAuraContainer                                                             = {
            setAllPoints                                                                    = true,
            refresh                                                                         = AshBlzSkinApi.UnitAura(),
            buffWidth                                                                       = AshBlzSkinApi.OnConfigChanged():Map(function() return DB().Appearance.Aura.AuraSize end),
            buffHeight                                                                      = AshBlzSkinApi.OnConfigChanged():Map(function() return DB().Appearance.Aura.AuraSize end)
        }
    },

    [AshPetUnitFrame]                                                                       = {
        frameStrata                                                                         = "MEDIUM",
        alpha                                                                               = AshBlzSkinApi.UnitPetInRange():Map('v=> v and 1 or 0.55'), 

        BackgroundTexture                                                                   = {
            file                                                                            = AshBlzSkinApi.UnitFrameBackground(),
            texCoords                                                                       = RectType(0, 1, 0, 0.53125),
            setAllPoints                                                                    = true,
            ignoreParentAlpha                                                               = true,
            drawLayer                                                                       = "BACKGROUND"
        },

        -- 宠物名字
        NameLabel                                                                           = {
            SHARE_NAMELABEL_SKIN,
        
            fontObject                                                                      = GameFontWhiteTiny,
            text                                                                            = Wow.UnitName(),
            location                                                                        = {
                Anchor("TOPLEFT", 3, -3), 
                Anchor("TOPRIGHT", -3, -3)
            }
        },

        -- 主人名字
        Label                                                                               = {
            fontObject                                                                      = GameFontWhiteTiny,
            drawLayer                                                                       = "ARTWORK",
            wordWrap                                                                        = false,
            justifyH                                                                        = "LEFT",
            text                                                                            = AshBlzSkinApi.UnitPetOwnerName(),
            location                                                                        = {
                Anchor("TOPLEFT", 0, 0, "NameLabel", "BOTTOMLEFT"),
                Anchor("RIGHT", 0, 0, nil, "RIGHT"),
            }
        },

        --死亡图标
        AshBlzSkinDeadIcon                                                                  = {
            size                                                                            = AshBlzSkinApi.ResizeUnitFrameIcon(),
            location                                                                        = AshBlzSkinApi.RelocationUnitFrameBottomIcon(),
        },

        -- 仇恨指示器
        AshBlzSkinAggroHighlight                                                            = AshBlzSkinApi.PetAggroSkin(),

        -- 选中
        AshBlzSkinSelectionHighlightTexture                                                 = {},
        
        -- 标记图标
        RaidTargetIcon                                                                      = SHARE_RAIDTARGET_SKIN,

        -- 血条
        PredictionHealthBar                                                                 = {
            SHARE_HEALTHBAR_SKIN,
            statusBarColor                                                                  = AshBlzSkinApi.UnitPetColor(),
        },

        -- 能量条
        PowerBar                                                                            = AshBlzSkinApi.PetPowerBarSkin(),

        -- 施法条
        AshBlzSkinCastBar                                                                   = AshBlzSkinApi.CastBarSkin()
    },
}

Style.UpdateSkin(SKIN_NAME, SKIN_STYLE)
Style.ActiveSkin(SKIN_NAME)