Scorpio "AshToAsh.BlizzardSkin.Active" ""

HEALTHBAR           = (Scorpio.IsRetail or Scorpio.IsBCC or IsAddOnLoaded("LibHealComm-4.0") or pcall(_G.LibStub, "LibHealComm-4.0")) and "PredictionHealthBar" or "HealthBar"

local shareColor    = ColorType(0, 0, 0, 1)
local shareSize     = Size(1, 1)

local function resizeOnUnitFrameChanged(size)
    return Wow.FromFrameSize(UnitFrame):Map(function(w, h)
        local componentScale = min(w / 72, h / 36)
        return (size or 10) * componentScale
    end)
end

local function resizeUnitFrameIconOnSizeChange(size)
    return Wow.FromFrameSize(UnitFrame):Map(function(w, h)
        local componentScale = min(w / 72, h / 36)
        shareSize.width = (size or 15) * componentScale
        shareSize.height = (size or 15) * componentScale
        return shareSize
    end)
end

local shareAnchor1 = Anchor("TOP")
local shareLocation = {}

local function getAnchor(anchor, point, x, y, relativeTo, relativePoint)
    anchor.point            = point
    anchor.x                = x
    anchor.y                = y
    anchor.relativeTo       = relativeTo
    anchor.relativePoint    = relativePoint
    return anchor
end

local function getLocation(...)
    wipe(shareLocation)
    for i = 1, select("#", ...) do
        tinsert(shareLocation, select(i, ...))
    end
    return shareLocation
end

local relocationUnitFrameIconOnSizeChange = Wow.FromFrameSize(UnitFrame):Map(function(w, h)
    return getLocation(getAnchor(shareAnchor1, "BOTTOM", 0, h/3-4))
end)

-- Dispell debuf
SHARE_DISPELLDEBUFFPANEL_SKIN                                                               = {
    elementType                                                                             = AshBlzSkinDispellIcon,
    leftToRight                                                                             = false,
    topToBottom                                                                             = false,
    rowCount                                                                                = 1,
    columnCount                                                                             = 4,
    hSpacing                                                                                = 1.5,
    vSpacing                                                                                = 1,
    marginRight                                                                             = 3,
    marginTop                                                                               = 4.5,
    elementWidth                                                                            = resizeOnUnitFrameChanged(8),
    elementHeight                                                                           = resizeOnUnitFrameChanged(8)
}

-- Boss debuff
SHARE_BOSSDEBUFFPANEL_SKIN                                                                  = {
    elementType                                                                             = AshBlzSkinBossDebuffIcon,
    orientation                                                                             = Orientation.HORIZONTAL,
    leftToRight                                                                             = true,
    topToBottom                                                                             = false,
    rowCount                                                                                = 1,
    columnCount                                                                             = 1,
    marginLeft                                                                              = 3,
    hSpacing                                                                                = 1.5,
    vSpacing                                                                                = 1,
    elementWidth                                                                            = resizeOnUnitFrameChanged(15),
    elementHeight                                                                           = resizeOnUnitFrameChanged(15)
}                                                             

-- Debuff
SHARE_DEBUFFPANEL_SKIN                                                                      = {
    elementType                                                                             = AshBlzSkinDebuffIcon,
    orientation                                                                             = Orientation.HORIZONTAL,
    leftToRight                                                                             = true,
    topToBottom                                                                             = false,
    rowCount                                                                                = 1,
    columnCount                                                                             = AshBlzSkinApi.UnitBossAura():Map(function(val) return val and 1 or 3 end),
    marginLeft                                                                              = 1.5,
    hSpacing                                                                                = 1.5,
    vSpacing                                                                                = 1,
    elementWidth                                                                            = resizeOnUnitFrameChanged(),
    elementHeight                                                                           = resizeOnUnitFrameChanged(),
    location                                                                                = {
        Anchor("BOTTOMLEFT", 0, 0, "AshBlzSkinBossDebuffPanel", "BOTTOMRIGHT")      
    },      
    auraFilter                                                                              = Wow.Unit():Map(function(unit)
        return UnitCanAttack("player", unit) and "PLAYER|HARMFUL" or "HARMFUL"   
    end),       

    customFilter                                                                            = function(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID)
        return not (_AuraBlackList[spellID] or _EnlargeDebuffList[spellID]) 
    end,
}                                                                    

-- Buff
SHARE_BUFFPANEL_SKIN                                                                        = {
    elementType                                                                             = AshBlzSkinBuffIcon,
    orientation                                                                             = Orientation.HORIZONTAL,
    elementWidth                                                                            = resizeOnUnitFrameChanged(),
    elementHeight                                                                           = resizeOnUnitFrameChanged(),
    marginRight                                                                             = 3,
    rowCount                                                                                = 1,
    columnCount                                                                             = 3,
    leftToRight                                                                             = false,
    topToBottom                                                                             = false,
        
    customFilter                                                                            = function(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID) return not _AuraBlackList[spellID] end,
}

-- 标记
SHARE_RAIDTARGET_SKIN                                                                       = {
    drawLayer                                                                               = "OVERLAY",
    location                                                                                = {
        Anchor("TOPRIGHT", -3, -2)      
    },
    size                                                                                    = resizeUnitFrameIconOnSizeChange(14)
}

-- 名字
SHARE_NAMELABEL_SKIN                                                                        = {
    fontObject                                                                              = GameFontHighlightSmall,
    drawLayer                                                                               = "ARTWORK",
    wordWrap                                                                                = false,
    justifyH                                                                                = "LEFT",
    textColor                                                                               = NIL
}

-- 施法条
SHARE_CASTBAR_SKIN                                                                          = {
    height                                                                                  = 8,
    location                                                                                = {
        Anchor("TOPLEFT", 0, 0, "PowerBar", "TOPLEFT"),     
        Anchor("BOTTOMRIGHT", 0, 0, "PowerBar", "BOTTOMRIGHT")      
    },      

    Spark                                                                                   = {
        size                                                                                = Size(24, 24),
    }
}

--能量条
SHARE_POWERBAR_SKIN                                                                         = {
    useParentLevel                                                                          = true,
    statusBarTexture                                                                        = {
        file                                                                                = "Interface\\RaidFrame\\Raid-Bar-Resource-Fill",
        drawLayer                                                                           = "BORDER"
    }, 

    BackgroundTexture                                                                       = {
        file                                                                                = "Interface\\RaidFrame\\Raid-Bar-Resource-Background",
        setAllPoints                                                                        = true,
        subLevel                                                                            = 2,
        drawLayer                                                                           = "BACKGROUND"
    }
}

-- 血条
SHARE_HEALTHBAR_SKIN                                                                        = {
    useParentLevel                                                                          = true,
    statusBarTexture                                                                        = {
        file                                                                                = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
        drawLayer                                                                           = "BORDER"
    },      
    location                                                                                = {
        Anchor("TOPLEFT", 1, -1),       
        Anchor("BOTTOMRIGHT", -1, 9)        
    },      
    statusBarColor                                                                          = AshBlzSkinApi.UnitColor(),

    BackgroundFrame                                                                         = NIL,

    -- 拥有驱散debuff的能力     
    IconTexture                                                                             = {
        drawLayer                                                                           = "BORDER",
        subLevel                                                                            = 2,
        location                                                                            = {
            Anchor("TOPLEFT"),      
            Anchor("BOTTOMRIGHT")       
        },      
        ignoreParentAlpha                                                                   = true,
        file                                                                                = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
        vertexColor                                                                         = AshBlzSkinApi.UnitDebuffCanDispellColor(),
        visible                                                                             = AshBlzSkinApi.UnitDebuffCanDispell(),

        AnimationGroup                                                                      = {
            playing                                                                         = AshBlzSkinApi.UnitDebuffCanDispell(),
            looping                                                                         = "REPEAT",

            Alpha1                                                                          = {
                order                                                                       = 1,
                duration                                                                    = 0.5,
                fromAlpha                                                                   = 0,
                toAlpha                                                                     = 1
            },      
            Alpha2                                                                          = {
                order                                                                       = 2,
                duration                                                                    = 0.5,
                fromAlpha                                                                   = 1,
                toAlpha                                                                     = 0
            }
        }
    }
}
SKIN_STYLE =                                                                                {
    [AshBlzSkinBuffIcon]                                                                    = {
        IconTexture                                                                         = {
            drawLayer                                                                       = "ARTWORK",
            setAllPoints                                                                    = true,
            file                                                                            = Wow.FromPanelProperty("AuraIcon")
        },

        Label                                                                               = {
            drawLayer                                                                       = "OVERLAY",
            fontObject                                                                      = NumberFontNormalSmall,
            location                                                                        = {
                Anchor("BOTTOMRIGHT", 0, 0)
            },
            text                                                                            = Wow.FromPanelProperty("AuraCount"):Map(function(val)
                if val >= 100 then
                    return BUFF_STACKS_OVERFLOW
                elseif val > 1 then
                    return val
                else
                    return ""
                end
            end),
        },

        Cooldown                                                                            = {
            setAllPoints                                                                    = true,
            enableMouse                                                                     = false,
            cooldown                                                                        = Wow.FromPanelProperty("AuraCooldown"),
            reverse                                                                         = true
        },
    },

    [AshBlzSkinClassBuffIcon]                                                               = {
        enableMouse                                                                         = false
    },

    [AshBlzSkinDebuffIcon]                                                                  = {
        BackgroundTexture                                                                   = {
            drawLayer                                                                       = "OVERLAY",
            file                                                                            = "Interface\\Buttons\\UI-Debuff-Overlays",
            location                                                                        = {
                Anchor("TOPLEFT", -1, 1),
                Anchor("BOTTOMRIGHT", 1, -1)
            },
            texCoords                                                                       = RectType(0.296875, 0.5703125, 0, 0.515625),
            vertexColor                                                                     = Wow.FromPanelProperty("AuraDebuff"):Map(function(dtype) return DebuffTypeColor[dtype] or DebuffTypeColor["none"] end)
        }
    },

    -- Boss debuff icon
    [AshBlzSkinBossDebuffIcon]                                                              = {
        Cooldown                                                                            = {
            setAllPoints                                                                    = true,
            enableMouse                                                                     = false,
            cooldown                                                                        = Wow.FromPanelProperty("AuraCooldown"),
            reverse                                                                         = true
        },

        auraFilter                                                                          = Wow.FromPanelProperty("AuraFilter")
    },

    [AshBlzSkinDispellIcon]                                                                 = {
        IconTexture                                                                         = {
            drawLayer                                                                       = "ARTWORK",
            setAllPoints                                                                    = true,
            file                                                                            = Wow.FromPanelProperty("AuraDebuff"):Map(function(dtype)
                return "Interface\\RaidFrame\\Raid-Icon-Debuff"..dtype
            end),
            texCoords                                                                       = RectType(0.125, 0.875, 0.125, 0.875)
        }
    },

    [AshUnitFrame]                                                                          = {
        inherit                                                                             = "default",

        frameStrata                                                                         = "LOW",
        alpha                                                                               = Wow.UnitInRange():Map('v=>v and 1 or 0.55'),
        
        -- 去除默认皮肤的目标指示器
        Label2                                                                              = NIL,
        Label3                                                                              = NIL,

        BackgroundTexture                                                                   = {
            file                                                                            = "Interface\\RaidFrame\\Raid-Bar-Hp-Bg",
            texCoords                                                                       = RectType(0, 1, 0, 0.53125),
            setAllPoints                                                                    = true,
            ignoreParentAlpha                                                               = true,
            drawLayer                                                                       = "BACKGROUND"
        },

        -- 选中
        AshBlzSkinSelectionHighlightTexture                                                 = {},

        -- 仇恨指示器
        AshBlzSkinAggroHighlight                                                            = {},

        -- 名字
        NameLabel                                                                           = {
            SHARE_NAMELABEL_SKIN,

            text                                                                            = Wow.UnitName(),
            location                                                                        = {
                Anchor("TOPLEFT", 0, -1, "RoleIcon", "TOPRIGHT"), 
                Anchor("TOPRIGHT", -3, -3) 
            }
        },

        -- 血量文本
        HealthLabel                                                                         = {
            location                                                                        = {
                Anchor("CENTER"),
                Anchor("TOP", 0, -2, "NameLabel", "BOTTOM")
            },
            text                                                                            = Wow.UnitHealthPercent():Map(function(percent) return percent.."%" end),
            fontObject                                                                      = SystemFont_Small,
            textColor                                                                       = Color.RED,
            visible                                                                         = Wow.UnitHealthPercent():Map(function(percent) return percent <= 35 and percent > 0 end)
        },

        -- 死亡图标
        AshBlzSkinDeadIcon                                                                  = {
            size                                                                            = resizeUnitFrameIconOnSizeChange(),
            location                                                                        = relocationUnitFrameIconOnSizeChange,
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
            size                                                                            = Size(12, 12)
        },

        -- 主坦克、主助理
        RaidRosterIcon                                                                      = {
            location                                                                        = {
                Anchor("TOPRIGHT", -1, 0, "LeaderIcon", "TOPLEFT")
            },
            size                                                                            = Size(12, 12),
        },

        -- 复活图标，不需要了，用CenterStatusIcon
        ResurrectIcon                                                                       = NIL,

        -- 标记图标
        RaidTargetIcon                                                                      = SHARE_RAIDTARGET_SKIN,

        -- 离线图标
        DisconnectIcon                                                                      = {
            location                                                                        = relocationUnitFrameIconOnSizeChange,
            size                                                                            = resizeUnitFrameIconOnSizeChange()
        },

        -- 准备就绪
        ReadyCheckIcon                                                                      = {
            drawLayer                                                                       = "OVERLAY",
            location                                                                        = relocationUnitFrameIconOnSizeChange,
            size                                                                            = resizeUnitFrameIconOnSizeChange()
        },

        -- 中间状态图标
        AshBlzSkinCenterStatusIcon                                                          = {
            location                                                                        = Wow.FromFrameSize(UnitFrame):Map(function(w, h)
                return getLocation(getAnchor(shareAnchor1, "CENTER", 0, h / 3 + 2, nil, "BOTTOM"))
            end),
            size                                                                            = resizeUnitFrameIconOnSizeChange(22),
            visible                                                                         = AshBlzSkinApi.UnitCenterStatusIconVisible(),
            unit                                                                            = Wow.Unit()
        },

        -- 血条
        [HEALTHBAR]                                                                         = SHARE_HEALTHBAR_SKIN,

        -- 能量条
        PowerBar                                                                            = {
            SHARE_POWERBAR_SKIN,

            value                                                                           = AshBlzSkinApi.UnitPower(),
            minMaxValues                                                                    = AshBlzSkinApi.UnitPowerMax(),
            statusBarColor                                                                  = AshBlzSkinApi.UnitPowerColor(),
            location                                                                        = {
                Anchor("TOPLEFT", 0, 0, HEALTHBAR, "BOTTOMLEFT"),       
                Anchor("BOTTOMRIGHT", -1, 1)
            },
        },

        -- 施法条
        AshBlzSkinCastBar                                                                   = SHARE_CASTBAR_SKIN,

        BuffPanel                                                                           = NIL,

        -- Buff
        AshBlzSkinBuffPanel                                                                 = {
            SHARE_BUFFPANEL_SKIN,

            location                                                                        = {
                Anchor("BOTTOMRIGHT", 0, 1.5, HEALTHBAR, "BOTTOMRIGHT") 
            },
        },

        DebuffPanel                                                                         = NIL,

        -- Debuff
        AshBlzSkinDebuffPanel                                                               = SHARE_DEBUFFPANEL_SKIN,

        EnlargeDebuffPanel                                                                  = NIL,

        --  Boss debuff
        AshBlzSkinBossDebuffPanel                                                           = {
            SHARE_BOSSDEBUFFPANEL_SKIN,

            location                                                                        = {
                Anchor("BOTTOMLEFT", 0, 1.5, HEALTHBAR, "BOTTOMLEFT")
            }
        },

        -- 职业buff
        ClassBuffPanel                                                                      = {
            elementType                                                                     = AshBlzSkinClassBuffIcon,
            location                                                                        = relocationUnitFrameIconOnSizeChange,
            rowCount                                                                        = 1,
            columnCount                                                                     = 1,
            visible                                                                         = AshBlzSkinApi.UnitIsPlayer(),
            elementWidth                                                                    = resizeOnUnitFrameChanged(),
            elementHeight                                                                   = resizeOnUnitFrameChanged()
        },

        -- 可驱散debuff (是可驱散类型即可驱散debuff)
        AshBlzSkinDispellDebuffPanel                                                        = {
            SHARE_DISPELLDEBUFFPANEL_SKIN,

            visible                                                                         = AshBlzSkinApi.UnitIsPlayer(),
            location                                                                        = {
                Anchor("TOPRIGHT", 0, 0, HEALTHBAR, "TOPRIGHT")
            }
        }
    },

    [AshPetUnitFrame]                                                                       = {
        frameStrata                                                                         = "LOW",
        alpha                                                                               = AshBlzSkinApi.UnitPetInRange():Map('v=> v and 1 or 0.55'), 

        BackgroundTexture                                                                   = {
            file                                                                            = "Interface\\RaidFrame\\Raid-Bar-Hp-Bg",
            texCoords                                                                       = RectType(0, 1, 0, 0.53125),
            setAllPoints                                                                    = true,
            ignoreParentAlpha                                                               = true,
            drawLayer                                                                       = "BACKGROUND"
        },

        -- 名字
        NameLabel                                                                           = {
            SHARE_NAMELABEL_SKIN,

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
                Anchor("TOPLEFT", 0, -select(2, GameFontHighlightSmall:GetFont()), "NameLabel", "TOPLEFT"),
                Anchor("TOPRIGHT", 0, -select(2, GameFontHighlightSmall:GetFont()), "NameLabel", "TOPRIGHT"),
            }
        },

        --死亡图标
        AshBlzSkinDeadIcon                                                                  = {
            size                                                                            = resizeUnitFrameIconOnSizeChange(),
            location                                                                        = relocationUnitFrameIconOnSizeChange,
        },

        -- 仇恨指示器
        AshBlzSkinAggroHighlight                                                            = {
            visible                                                                         = AshBlzSkinApi.UnitPetThreatLevel():Map("l=> l>0"),
            vertexColor                                                                     = AshBlzSkinApi.UnitPetThreatLevel():Map(function(level)
                shareColor.r, shareColor.g, shareColor.b, shareColor.a = GetThreatStatusColor(level)
                return shareColor
            end)
        },

        -- 选中
        AshBlzSkinSelectionHighlightTexture                                                 = {},
        
        -- 标记图标
        RaidTargetIcon                                                                      = SHARE_RAIDTARGET_SKIN,

        -- 血条
        HealthBar                                                                           = SHARE_HEALTHBAR_SKIN,

        -- 能量条
        PowerBar                                                                            = {
            SHARE_POWERBAR_SKIN,

            location                                                                        = {
                Anchor("TOPLEFT", 0, 0, "HealthBar", "BOTTOMLEFT"),
                Anchor("BOTTOMRIGHT", -1, 1)
            }
        },

        -- 施法条
        AshBlzSkinCastBar                                                                   = SHARE_CASTBAR_SKIN,

        -- Buff
        AshBlzSkinBuffPanel                                                                 = {
            SHARE_BUFFPANEL_SKIN,

            location                                                                        = {
                Anchor("BOTTOMRIGHT", 0, 1.5, "HealthBar", "BOTTOMRIGHT") 
            },
        },
        
        -- Debuff
        AshBlzSkinDebuffPanel                                                               = SHARE_DEBUFFPANEL_SKIN,

        --  Boss debuff
        AshBlzSkinBossDebuffPanel                                                           = {
            SHARE_BOSSDEBUFFPANEL_SKIN,

            location                                                                        = {
                Anchor("BOTTOMLEFT", 0, 1.5, "HealthBar", "BOTTOMLEFT")
            }
        },

        -- 可驱散debuff (是可驱散类型即可驱散debuff)
        AshBlzSkinDispellDebuffPanel                                                        = {
           SHARE_DISPELLDEBUFFPANEL_SKIN,
        
           location                                                                         = {
               Anchor("TOPRIGHT", 0, 0, "HealthBar", "TOPRIGHT")
           }
        }
    },
}

Style.UpdateSkin(SKIN_NAME, SKIN_STYLE)
Style.ActiveSkin(SKIN_NAME)