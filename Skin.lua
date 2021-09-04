Scorpio "AshToAsh.BlizzardSkin.Active" ""

SKIN_NAME = "AshToAsh.BlizzardSkin"

Style.RegisterSkin(SKIN_NAME)

HEALTHBAR = (Scorpio.IsRetail or IsAddOnLoaded("LibHealComm-4.0") or pcall(_G.LibStub, "LibHealComm-4.0")) and "PredictionHealthBar" or "HealthBar"

local shareColor    = ColorType(0, 0, 0, 1)
local shareSize     = Size(1, 1)

local function resizeUnitFrameAuraOnSizeChange(size)
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


local function isBossAura(...)
	return select(12, ...)
end

-- 直接抄的，不想研究taint了 CompactUnitFrame_UtilShouldDisplayBuff
local function shouldDisplayBuff(...)
	local name, icon, count, debuffType, duration, expirationTime, unitCaster, canStealOrPurge, _, spellId, canApplyAura = ...

	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

	if ( hasCustom ) then
		return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"))
	else
		return (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellId)
	end
end
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
            drawLayer                                                                       = "BORDER",
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

        -- 目标选中边框
        AshBlzSkinSelectionHighlightTexture                                                 = {
            drawLayer                                                                       = "OVERLAY",
            file                                                                            = "Interface\\RaidFrame\\Raid-FrameHighlights",
            texCoords                                                                       = RectType(0.00781250, 0.55468750, 0.28906250, 0.55468750),
            setAllPoints                                                                    = true,
            ignoreParentAlpha                                                               = true,
            visible                                                                         = Wow.UnitIsTarget()
        },

        -- 仇恨指示器
        AshBlzSkinAggroHighlight                                                            = {
            drawLayer                                                                       = "ARTWORK",
            file                                                                            = "Interface\\RaidFrame\\Raid-FrameHighlights",
            texCoords                                                                       = RectType(0.00781250, 0.55468750, 0.00781250, 0.27343750),
            setAllPoints                                                                    = true,
            visible                                                                         = Wow.UnitThreatLevel():Map("l=> l>0"),
            vertexColor                                                                     = Wow.UnitThreatLevel():Map(function(level)
                shareColor.r, shareColor.g, shareColor.b, shareColor.a = GetThreatStatusColor(level)
                return shareColor
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
            file                                                                            = "Interface\\EncounterJournal\\UI-EJ-Icons",
            texCoords                                                                       = RectType(0.375, 0.5, 0, 0.5),
            visible                                                                         = AshBlzSkinApi.UnitIsDead()
        },

        -- 角色职责图标
        RoleIcon                                                                            = Scorpio.IsRetail and {
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
        } or nil,

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

        -- 复活图标
        ResurrectIcon                                                                       = {
            drawLayer                                                                       = "OVERLAY",
            location                                                                        = {
                Anchor("BOTTOM", 0, 0, HEALTHBAR, "BOTTOM")
            },
            size                                                                            = resizeUnitFrameIconOnSizeChange(18)
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
            size                                                                            = resizeUnitFrameIconOnSizeChange()
        },

        -- 准备就绪
        ReadyCheckIcon                                                                      = {
            drawLayer                                                                       = "OVERLAY",
            location                                                                        = relocationUnitFrameIconOnSizeChange,
            size                                                                            = resizeUnitFrameIconOnSizeChange()
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
            statusBarColor                                                                  = AshBlzSkinApi.UnitColor(),

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
            value                                                                           = AshBlzSkinApi.UnitPower(),
            minMaxValues                                                                    = AshBlzSkinApi.UnitPowerMax(),
            statusBarColor                                                                  = AshBlzSkinApi.UnitPowerColor(),

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

        -- Buff
        BuffPanel                                                                           = {
            elementType                                                                     = AshBlzSkinBuffIcon,
            orientation                                                                     = Orientation.HORIZONTAL,
            elementWidth                                                                    = resizeUnitFrameAuraOnSizeChange(),
            elementHeight                                                                   = resizeUnitFrameAuraOnSizeChange(),
            marginRight                                                                     = 3,
            rowCount                                                                        = 1,
            columnCount                                                                     = 3,
            leftToRight                                                                     = false,
            topToBottom                                                                     = false,
            location                                                                        = {
                Anchor("BOTTOMRIGHT", 0, 1.5, HEALTHBAR, "BOTTOMRIGHT")
            },
            customFilter                                                                    = function(...) return not isBossAura(...) and shouldDisplayBuff(...) and not _AuraBlackList[select(10, ...)] end,
        },

        DebuffPanel                                                                         = NIL,

        -- Debuff
        AshBlzSkinDebuffPanel                                                               = {
            elementType                                                                     = AshBlzSkinDebuffIcon,
            orientation                                                                     = Orientation.HORIZONTAL,
            leftToRight                                                                     = true,
            topToBottom                                                                     = false,
            rowCount                                                                        = 1,
            columnCount                                                                     = AshBlzSkinApi.UnitBossAura():Map(function(val) return val and 1 or 3 end),
            marginLeft                                                                      = 1.5,
            hSpacing                                                                        = 1.5,
            vSpacing                                                                        = 1,
            elementWidth                                                                    = resizeUnitFrameAuraOnSizeChange(),
            elementHeight                                                                   = resizeUnitFrameAuraOnSizeChange(),
            location                                                                        = {
                Anchor("BOTTOMLEFT", 0, 0, "AshBlzSkinBossDebuffPanel", "BOTTOMRIGHT")
            },
            auraFilter                                                                      = Wow.Unit():Map(function(unit)
                return UnitCanAttack("player", unit) and "PLAYER|HARMFUL" or "HARMFUL"
            end),
            
            customFilter                                                                    = function(name, icon, count, dtype, duration, expires, caster, isStealable, nameplateShowPersonal, spellID)
                return not (_AuraBlackList[spellID] or _EnlargeDebuffList[spellID]) 
            end,
        },

        EnlargeDebuffPanel                                                                  = NIL,

        --  Boss debuff
        AshBlzSkinBossDebuffPanel                                                           = {
            elementType                                                                     = AshBlzSkinBossDebuffIcon,
            orientation                                                                     = Orientation.HORIZONTAL,
            leftToRight                                                                     = true,
            topToBottom                                                                     = false,
            rowCount                                                                        = 1,
            columnCount                                                                     = 1,
            marginLeft                                                                      = 3,
            hSpacing                                                                        = 1.5,
            vSpacing                                                                        = 1,
            elementWidth                                                                    = Wow.FromFrameSize(UnitFrame):Map(function(w, h)
                local componentScale = min(w / 72, h / 36)
                return 15 * componentScale
            end),
            elementHeight                                                                   = Wow.FromFrameSize(UnitFrame):Map(function(w, h)
                local componentScale = min(w / 72, h / 36)
                return 15 * componentScale
            end),
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
            elementWidth                                                                    = resizeUnitFrameAuraOnSizeChange(),
            elementHeight                                                                   = resizeUnitFrameAuraOnSizeChange()
        },

        -- 可驱散debuff (是可驱散类型即可驱散debuff)
        AshBlzSkinDispellDebuffPanel                                                        = {
            elementType                                                                     = AshBlzSkinDispellIcon,
            leftToRight                                                                     = false,
            topToBottom                                                                     = false,
            rowCount                                                                        = 1,
            columnCount                                                                     = 4,
            hSpacing                                                                        = 1.5,
            vSpacing                                                                        = 1,
            marginRight                                                                     = 3,
            marginTop                                                                       = 4.5,
            visible                                                                         = AshBlzSkinApi.UnitIsPlayer(),
            elementWidth                                                                    = resizeUnitFrameAuraOnSizeChange(8),
            elementHeight                                                                   = resizeUnitFrameAuraOnSizeChange(8),
            location                                                                        = {
                Anchor("TOPRIGHT", 0, 0, HEALTHBAR, "TOPRIGHT")
            }
        }
    }
}

Style.UpdateSkin(SKIN_NAME, SKIN_STYLE)
Style.ActiveSkin(SKIN_NAME)