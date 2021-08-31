Scorpio "AshToAsh.BlizzardSkin.Active" ""

SKIN_NAME = "AshToAsh.BlizzardSkin"

Style.RegisterSkin(SKIN_NAME)

HEALTHBAR = (Scorpio.IsRetail or IsAddOnLoaded("LibHealComm-4.0") or pcall(_G.LibStub, "LibHealComm-4.0")) and "PredictionHealthBar" or "HealthBar"

local resizeUnitFrameIconOnSizeChange = Wow.FromFrameSize(UnitFrame):Map(function(w, h)
    local componentScale = min(w / 72, h / 36)
    return Size(15 * componentScale, 15 * componentScale)
end)

local relocationUnitFrameIconOnSizeChange = Wow.FromFrameSize(UnitFrame):Map(function(w, h)
    return { Anchor("BOTTOM", 0, h/3 - 4) }
end)

SKIN_STYLE =                                                                                {
    [AshUnitFrame]                                                                          = {
        inherit                                                                             = "default",

        frameStrata                                                                         = "LOW",
        alpha                                                                               = Wow.UnitInRange():Map('v=>v and 1 or 0.55'),
        
        Label2                                                                              = NIL,
        Label3                                                                              = NIL,

        BackgroundTexture                                                                   = {
            file                                                                            = "Interface\\RaidFrame\\Raid-Bar-Hp-Bg",
            texCoords                                                                       = RectType(0, 1, 0, 0.53125),
            setAllPoints                                                                    = true,
            ignoreParentAlpha                                                               = true,
            drawLayer                                                                       = "BACKGROUND"
        },

        -- 目标选中边框
        AshBlzSkinSelectionHighlightTexture                                                 = {
            drawLayer                                                                       = "OVERLAY",
            file                                                                            = "Interface\\RaidFrame\\Raid-FrameHighlights",
            texCoords                                                                       = RectType(0.00781250, 0.55468750, 0.28906250, 0.55468750),
            setAllPoints                                                                    = true,
            ignoreParentAlpha                                                               = true,
            visible                                                                         = Wow.UnitIsTarget():Map(function(val) return val end)
        },

        -- 仇恨指示器
        AshBlzSkinAggroHighlight                                                            = {
            drawLayer                                                                       = "ARTWORK",
            file                                                                            = "Interface\\RaidFrame\\Raid-FrameHighlights",
            texCoords                                                                       = RectType(0.00781250, 0.55468750, 0.00781250, 0.27343750),
            setAllPoints                                                                    = true,
            visible                                                                         = Wow.UnitThreatLevel():Map("l=> l>0"),
            vertexColor                                                                     = Wow.UnitThreatLevel():Map(function(level)
                return ColorType(GetThreatStatusColor(level))
            end)
        },

        -- 名字
        NameLabel                                                                           = {
            fontObject                                                                      = GameFontHighlightSmall,
            drawLayer                                                                       = "ARTWORK",
            wordWrap                                                                        = false,
            justifyH                                                                        = "LEFT",
            textColor                                                                       = NIL,
            location                                                                        = {
                Anchor("TOPLEFT", 0, -1, "RoleIcon", "TOPRIGHT"),
                Anchor("TOPRIGHT", -3, -3)
            }
        },

        -- 角色职责图标
        RoleIcon                                                                            = Scorpio.IsRetail and {
            location                                                                        = {
                Anchor("TOPLEFT", 3, -2)
            },
            size                                                                            = Wow.UnitRoleVisible():Map(function(val)
                return val and Size(12, 12) or Size(1, 12)
            end),
            visible                                                                         = true
        } or nil,

        -- 队长图标
        LeaderIcon                                                                          = {
            location                                                                        = {
                Anchor("TOPRIGHT")
            },
            size                                                                            = Size(12, 12)
        },

        -- 主坦克、主助理
        RaidRosterIcon                                                                      = {
            location                                                                        = { 
                Anchor("TOPRIGHT")
            },
            size                                                                            = Size(12, 12)
        },

        -- 复活图标
        ResurrectIcon                                                                       = {
            location                                                                        = {
                Anchor("BOTTOM", 0, 0, HEALTHBAR, "BOTTOM")
            },
            size                                                                            = Size(36, 36)
        },

        -- 标记图标
        RaidTargetIcon                                                                      = {
            drawLayer                                                                       = "OVERLAY",
            location                                                                        = {
                Anchor("TOPRIGHT")
            },
            size                                                                            = Size(24, 24)
        },

        -- 离线图标
        DisconnectIcon                                                                      = {
            location                                                                        = relocationUnitFrameIconOnSizeChange,
            size                                                                            = resizeUnitFrameIconOnSizeChange
        },

        -- 准备就绪
        ReadyCheckIcon                                                                      = {
            drawLayer                                                                       = "OVERLAY",
            location                                                                        = relocationUnitFrameIconOnSizeChange,
            size                                                                            = resizeUnitFrameIconOnSizeChange
        },

        -- 血条
        [HEALTHBAR]                                                                         = {
            useParentLevel                                                                  = true,
            statusBarTexture                                                                = {
                file                                                                        = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
                drawLayer                                                                   = "BORDER"
            },
            location                                                                        = {
                Anchor("TOPLEFT", 1, -1),
                Anchor("BOTTOMRIGHT", -1, 9)
            },
            statusBarColor                                                                  = AshBlzSkinApi.UnitCombineDisconnectedColor(),

            BackgroundFrame                                                                 = NIL
        },

        -- 能量条
        PowerBar                                                                            = {
            useParentLevel                                                                  = true,
            statusBarTexture                                                                = {
                file                                                                        = "Interface\\RaidFrame\\Raid-Bar-Resource-Fill",
                drawLayer                                                                   = "BORDER"
            },
            location                                                                        = {
                Anchor("TOPLEFT", 0, 0, HEALTHBAR, "BOTTOMLEFT"),
                Anchor("BOTTOMRIGHT", -1, 1)
            },

            BackgroundTexture                                                               = {
                file                                                                        = "Interface\\RaidFrame\\Raid-Bar-Resource-Background",
                setAllPoints                                                                = true,
                subLevel                                                                    = 2,
                drawLayer                                                                   = "BACKGROUND"
            }
        },

        -- 施法条
        AshBlzSkinCastBar                                                                   = {
            useParentLevel                                                                  = true,
            height                                                                          = 8,
            location                                                                        = {
                Anchor("TOPLEFT", 0, 0, "PowerBar", "TOPLEFT"),
                Anchor("BOTTOMRIGHT", 0, 0, "PowerBar", "BOTTOMRIGHT")
            },
            statusBarTexture                                                                = {
                file                                                                        = "Interface\\TargetingFrame\\UI-StatusBar"
            },
            statusBarColor                                                                  = AshBlzSkinApi.UnitCastBarColor(),
            cooldown                                                                        = Wow.UnitCastCooldown(),
            reverse                                                                         = Wow.UnitCastChannel(),

            Spark                                                                           = {
                size                                                                        = Size(24, 24),
                drawLayer                                                                   = "OVERLAY",
                file                                                                        = "Interface\\CastingBar\\UI-CastingBar-Spark",
                alphaMode                                                                   = "ADD"
            },

            Label                                                                           = {
                justifyH                                                                    = "CENTER",
                drawLayer                                                                   = "OVERLAY",
                fontObject                                                                  = GameFontWhiteTiny2,
                text                                                                        = Wow.UnitCastName(),
                setAllPoints                                                                = true
            }
        },

        -- 不显示buff
        BuffPanel                                                                           = NIL,

        -- debuff
        DebuffPanel                                                                         = {
            location                                                                        = {
                Anchor("BOTTOMLEFT", 0, 0, HEALTHBAR, "BOTTOMLEFT")
            },
            orientation                                                                     = Orientation.HORIZONTAL,
            leftToRight                                                                     = true,
            rowCount                                                                        = 1,
            columnCount                                                                     = 3,
            elementWidth                                                                    = 16,
            elementHeight                                                                   = 16,
        },

        -- 特殊buff
        ClassBuffPanel                                                                      = {
            location                                                                        = relocationUnitFrameIconOnSizeChange,
            rowCount                                                                        = 1,
            columnCount                                                                     = 3,
            elementWidth                                                                    = 20,
            elementHeight                                                                   = 20
        }
    }
}

Style.UpdateSkin(SKIN_NAME, SKIN_STYLE)
Style.ActiveSkin(SKIN_NAME)