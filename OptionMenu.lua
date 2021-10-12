Scorpio "AshToAsh.BlizzardSkin.OptionMenu" ""

-------------------------------------------------
-- Menu
-------------------------------------------------
DEFAULT_TEXTURE = "ASH_TO_ASH_BLZ_SKIN_TEXTURE_DEFAULT"

local function GetTextureMenus(type, check)
    local menu = {}
    menu.check                                                                                                              = check

    tinsert(menu, {
        text                                                                                                                = L["default"],
        checkvalue                                                                                                          = DEFAULT_TEXTURE
    })

    local libSharedMedia = GetLibSharedMedia()
    if libSharedMedia then
        if type == "StatusBar" then
            type = libSharedMedia.MediaType.STATUSBAR
        elseif type == "Background" then
            type = libSharedMedia.MediaType.BACKGROUND
        end

        local textures = libSharedMedia:List(type)
        if textures then
            for _, name in ipairs_reverse(textures) do
                if strlower(name) ~= "none" then
                    tinsert(menu, {
                        text                                                                                                    = name,
                        checkvalue                                                                                              = name
                    })
                end
            end
        end
    end

    return menu
end

local function GetFontMenu(check)
    local menu = {}
    menu.check                                                                                                              = check

    local libSharedMedia = GetLibSharedMedia()
    if libSharedMedia then
        local fonts = libSharedMedia:List(libSharedMedia.MediaType.FONT)
        if fonts then
            for _, name in ipairs_reverse(fonts) do
                tinsert(menu, {
                    text                                                                                                    = name,
                    checkvalue                                                                                              = name
                })
            end
        end
    end

    return menu
end

local function GetFontOutlineMenu(check)
    local menu = {
        check                                                                                                               = check,
        {
            text                                                                                                            = L["font_outline_none"],
            checkvalue                                                                                                      = "NONE"
        },
        {
            text                                                                                                            = L["font_outline_normal"],
            checkvalue                                                                                                      = "NORMAL"
        },
        {
            text                                                                                                            = L["font_outline_thick"],
            checkvalue                                                                                                      = "THICK"
        }
    }

    return menu
end

-- 外观菜单
local function GetAppearanceMenu()
    local menu = {
        -- 施法条
        {
            text                                                                                                            = L["cast_bar"],
            submenu                                                                                                         = {
                {
                    -- 可见性
                    text                                                                                                    = L["visibility"],
                    disabled                                                                                                = DB().Appearance.PowerBar.Visibility ~= Visibility.SHOW_ALWAYS,
                    tiptitle                                                                                                = L["tips"],
                    tiptext                                                                                                 = L["power_bar_visibility_tips"],
                    submenu                                                                                                 = {
                        check                                                                                               = {
                            get                                                                                             = function()
                                return DB().Appearance.CastBar.Visibility
                            end,
                            set                                                                                             = function(value)
                                DB().Appearance.CastBar.Visibility = value
                                SendConfigChanged()
                            end
                        },
                        {
                            text                                                                                            = L["visibility_hide"],
                            checkvalue                                                                                      = Visibility.HIDE
                        },
                        {
                            text                                                                                            = L["visibility_show_only_party"],
                            checkvalue                                                                                      = Visibility.SHOW_ONLY_PARTY
                        },
                        {
                            text                                                                                            = L["visibility_show_always"],
                            checkvalue                                                                                      = Visibility.SHOW_ALWAYS
                        },
                    }
                },
                -- 材质
                {
                    text                                                                                                    = L["texture"],
                    submenu                                                                                                 = GetTextureMenus("StatusBar", {
                        get                                                                                                 = function()
                            return DB().Appearance.CastBar.Texture or DEFAULT_TEXTURE
                        end,
                        set                                                                                                 = function(value)
                            DB().Appearance.CastBar.Texture = (value ~= DEFAULT_TEXTURE and value or nil)
                            SendConfigChanged()
                        end
                    })
                },
                -- 字体
                {
                    text                                                                                                    = L["font"],
                    submenu                                                                                                 = {
                        -- 字体路径
                        {
                            text                                                                                            = L["font"],
                            submenu                                                                                         = GetFontMenu({
                                get                                                                                         = function()
                                    return DB().Appearance.CastBar.Font
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.CastBar.Font = value
                                    SendConfigChanged()
                                end
                            })
                        },
                        -- 字体描边
                        {
                            text                                                                                            = L["font_outline"],
                            submenu                                                                                         = GetFontOutlineMenu({
                                get                                                                                         = function()
                                    return DB().Appearance.CastBar.FontOutline
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.CastBar.FontOutline = value
                                    SendConfigChanged()
                                end
                            })
                        },
                        -- 字体大小
                        {
                            text                                                                                            = L["font_size"],
                            click                                                                                           = function()
                                local size = PickRange(L["font_size"], 8, 20, 1, DB().Appearance.CastBar.FontSize)
                                if size then
                                    DB().Appearance.CastBar.FontSize = size
                                    SendConfigChanged()
                                end
                            end
                        },
                        -- 单色
                        {
                            text                                                                                            = L["font_monochrome"],
                            check                                                                                           = {
                                get                                                                                         = function()
                                    return DB().Appearance.CastBar.FontMonochrome
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.CastBar.FontMonochrome = value
                                    SendConfigChanged()
                                end
                            }
                        }
                    }
                },
            }
        },
        -- 能量条
        {
            text                                                                                                            = L["power_bar"],
            submenu                                                                                                         = {
                {
                    -- 可见性
                    text                                                                                                    = L["visibility"],
                    submenu                                                                                                 = {
                        check                                                                                               = {
                            get                                                                                             = function()
                                return DB().Appearance.PowerBar.Visibility
                            end,
                            set                                                                                             = function(value)
                                DB().Appearance.PowerBar.Visibility = value
                                SendConfigChanged()
                            end
                        },
                        {
                            text                                                                                            = L["visibility_hide"],
                            checkvalue                                                                                      = Visibility.HIDE
                        },
                        {
                            text                                                                                            = L["visibility_show"],
                            checkvalue                                                                                      = Visibility.SHOW_ALWAYS
                        },
                    }
                },
                -- 材质
                {
                    text                                                                                                    = L["texture"],
                    submenu                                                                                                 = GetTextureMenus("StatusBar", {
                        get                                                                                                 = function()
                            return DB().Appearance.PowerBar.Texture or DEFAULT_TEXTURE
                        end,
                        set                                                                                                 = function(value)
                            DB().Appearance.PowerBar.Texture = (value ~= DEFAULT_TEXTURE and value or nil)
                            SendConfigChanged()
                        end
                    })
                },
                -- 背景材质
                {
                    text                                                                                                    = L["background_texture"],
                    submenu                                                                                                 = GetTextureMenus("Background", {
                        get                                                                                                 = function()
                            return DB().Appearance.PowerBar.Background or DEFAULT_TEXTURE
                        end,
                        set                                                                                                 = function(value)
                            DB().Appearance.PowerBar.Background = (value ~= DEFAULT_TEXTURE and value or nil)
                            SendConfigChanged()
                        end
                    })
                },
            }
        },
        -- 生命值
        {
            text                                                                                                            = L["health_bar"],
            submenu                                                                                                         = {
                -- 生命值数值
                {
                    text                                                                                                    = RAID_DISPLAY_HEALTH_TEXT,
                    submenu                                                                                                 = {
                        check                                                                                               = {
                            get                                                                                             = function()
                                return DB().Appearance.HealthBar.HealthText.Style
                            end,
                            set                                                                                             = function(value)
                                DB().Appearance.HealthBar.HealthText.Style = value
                                SendConfigChanged()
                            end
                        },
                        {
                            text                                                                                            = COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE,
                            checkvalue                                                                                      = HealthTextStyle.NONE
                        },
                        {
                            text                                                                                            = COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH,
                            checkvalue                                                                                      = HealthTextStyle.HEALTH
                        },
                        {
                            text                                                                                            = COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH,
                            checkvalue                                                                                      = HealthTextStyle.LOSTHEALTH
                        },
                        {
                            text                                                                                            = COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC,
                            checkvalue                                                                                      = HealthTextStyle.PERCENT
                        }
                    }
                },
                -- 生命值格式
                {
                    text                                                                                                    = L["health_text_format"],
                    submenu                                                                                                 = {
                        check                                                                                               = {
                            get                                                                                             = function()
                                return DB().Appearance.HealthBar.HealthText.TextFormat
                            end,
                            set                                                                                             = function(value)
                                DB().Appearance.HealthBar.HealthText.TextFormat = value
                                FireSystemEvent("UNIT_HEALTH", 'any')
                            end
                        },
                        {
                            text                                                                                            = L["health_text_format_normal"],
                            checkvalue                                                                                      = HealthTextFormat.NORMAL
                        },
                        {
                            text                                                                                            = L["health_text_format_kilo"],
                            checkvalue                                                                                      = HealthTextFormat.KILO
                        },
                        {
                            text                                                                                            = L["health_text_format_ten_thousand"],
                            checkvalue                                                                                      = HealthTextFormat.TEN_THOUSAND
                        }
                    }
                },
                -- 材质
                {
                    text                                                                                                    = L["texture"],
                    submenu                                                                                                 = GetTextureMenus("StatusBar", {
                        get                                                                                                 = function()
                            return DB().Appearance.HealthBar.Texture or DEFAULT_TEXTURE
                        end,
                        set                                                                                                 = function(value)
                            DB().Appearance.HealthBar.Texture = (value ~= DEFAULT_TEXTURE and value or nil)
                            SendConfigChanged()
                        end
                    })
                },
                -- 字体
                {
                    text                                                                                                    = L["font"],
                    submenu                                                                                                 = {
                        -- 字体路径
                        {
                            text                                                                                            = L["font"],
                            submenu                                                                                         = GetFontMenu({
                                get                                                                                         = function()
                                    return DB().Appearance.HealthBar.HealthText.Font
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.HealthBar.HealthText.Font = value
                                    SendConfigChanged()
                                end
                            })
                        },
                        -- 字体描边
                        {
                            text                                                                                            = L["font_outline"],
                            submenu                                                                                         = GetFontOutlineMenu({
                                get                                                                                         = function()
                                    return DB().Appearance.HealthBar.HealthText.FontOutline
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.HealthBar.HealthText.FontOutline = value
                                    SendConfigChanged()
                                end
                            })
                        },
                        -- 字体大小
                        {
                            text                                                                                            = L["font_size"],
                            click                                                                                           = function()
                                local size = PickRange(L["font_size"], 8, 20, 1, DB().Appearance.HealthBar.HealthText.FontSize)
                                if size then
                                    DB().Appearance.HealthBar.HealthText.FontSize = size
                                    SendConfigChanged()
                                end
                            end
                        },
                        -- 单色
                        {
                            text                                                                                            = L["font_monochrome"],
                            check                                                                                           = {
                                get                                                                                         = function()
                                    return DB().Appearance.HealthBar.HealthText.FontMonochrome
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.HealthBar.HealthText.FontMonochrome = value
                                    SendConfigChanged()
                                end
                            }
                        }
                    }
                },
                -- 生命值大小随框体缩放
                {
                    text                                                                                                    = L["name_scales_with_frame"],
                    check                                                                                                   = {
                        get                                                                                                 = function()
                            return DB().Appearance.HealthBar.HealthText.ScaleWithFrame
                        end,
                        set                                                                                                 = function(value)
                            DB().Appearance.HealthBar.HealthText.ScaleWithFrame = value
                            SendConfigChanged()
                        end
                    }
                },
            }
        },
        -- 名字
        {
            text                                                                                                            = NAME,
            submenu                                                                                                         = {
                -- 格式
                {
                    text                                                                                                    = L["name_format"],
                    submenu                                                                                                 = {
                        check                                                                                               = {
                            get                                                                                             = function()
                                return DB().Appearance.Name.Style
                            end,
                            set                                                                                             = function(value)
                                DB().Appearance.Name.Style = value
                                FireSystemEvent("UNIT_NAME_UPDATE", 'any')
                            end
                        },
                        {
                            text                                                                                            = L["name_format_noserver"],
                            checkvalue                                                                                      = NameStyle.PLAYERNAME
                        },
                        {
                            text                                                                                            = L["name_format_server_shorthand"],
                            checkvalue                                                                                      = NameStyle.PLAYERNAME_SERVER_SHORTHAND
                        },
                        {
                            text                                                                                            = L["name_format_withserver"],
                            checkvalue                                                                                      = NameStyle.PLAYERNAME_SERVER
                        }
                    }
                },
                -- 昵称
                {
                    text                                                                                                    = L["nick_name"],
                    submenu                                                                                                 = {
                        -- 设置昵称
                        {
                            text                                                                                            = DB().Appearance.Name.Nickname and L["nick_name_format"]:format(DB().Appearance.Name.Nickname) or L["nick_name_setting"],
                            tiptitle                                                                                        = L["tips"],
                            tiptext                                                                                         = L["nick_name_setting"],
                            click                                                                                           = function()
                                local nickname = Input(L["nick_name_setting"])
                                if nickname and strlen(nickname) > 25 then
                                    ShowError(L["err_nickname_too_long"])
                                    return
                                end
                                DB().Appearance.Name.Nickname = nickname
                                FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_UPDATE", 'any')
                                FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_REFRESH", 'any')
                            end
                        },
                        -- 显示自己的昵称
                        {
                            text                                                                                            = L["show_nick_name_owns"],
                            check                                                                                           = {
                                get                                                                                         = function()
                                    return DB().Appearance.Name.ShowNicknameOwns
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.Name.ShowNicknameOwns = value
                                    FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_UPDATE", 'any')
                                end
                            }
                        },
                        -- 显示他人的昵称
                        {
                            text                                                                                            = L["show_nick_name_others"],
                            check                                                                                           = {
                                get                                                                                         = function()
                                    return DB().Appearance.Name.ShowNicknameOthers
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.Name.ShowNicknameOthers = value
                                    FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_UPDATE", 'any')
                                end
                            }
                        },
                        -- 对他人显示我的昵称
                        {
                            text                                                                                            = L["show_nick_name_to_others"],
                            tiptitle                                                                                        = L["tips"],
                            tiptext                                                                                         = L["show_nick_name_to_others_tips"],
                            check                                                                                           = {
                                get                                                                                         = function()
                                    return DB().Appearance.Name.ShowNicknameToOthers
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.Name.ShowNicknameToOthers = value
                                    FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_REFRESH", 'any')
                                end
                            }
                        }
                    }
                },
                -- 字体
                {
                    text                                                                                                    = L["font"],
                    submenu                                                                                                 = {
                        -- 字体路径
                        {
                            text                                                                                            = L["font"],
                            submenu                                                                                         = GetFontMenu({
                                get                                                                                         = function()
                                    return DB().Appearance.Name.Font
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.Name.Font = value
                                    SendConfigChanged()
                                end
                            })
                        },
                        -- 字体描边
                        {
                            text                                                                                            = L["font_outline"],
                            submenu                                                                                         = GetFontOutlineMenu({
                                get                                                                                         = function()
                                    return DB().Appearance.Name.FontOutline
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.Name.FontOutline = value
                                    SendConfigChanged()
                                end
                            })
                        },
                        -- 字体大小
                        {
                            text                                                                                            = L["font_size"],
                            click                                                                                           = function()
                                local size = PickRange(L["font_size"], 8, 20, 1, DB().Appearance.Name.FontSize)
                                if size then
                                    DB().Appearance.Name.FontSize = size
                                    SendConfigChanged()
                                end
                            end
                        },
                        -- 单色
                        {
                            text                                                                                            = L["font_monochrome"],
                            check                                                                                           = {
                                get                                                                                         = function()
                                    return DB().Appearance.Name.FontMonochrome
                                end,
                                set                                                                                         = function(value)
                                    DB().Appearance.Name.FontMonochrome = value
                                    SendConfigChanged()
                                end
                            }
                        }
                    }
                },
                -- 好友名字染色
                {
                    text                                                                                                    = L["friends_name_coloring"],
                    check                                                                                                   = {
                        get                                                                                                 = function()
                            return DB().Appearance.Name.FriendsNameColoring
                        end,
                        set                                                                                                 = function(value)
                            DB().Appearance.Name.FriendsNameColoring = value
                            SendConfigChanged()
                            FireSystemEvent("UNIT_NAME_UPDATE", 'any')
                        end
                    }
                },
                -- 名字大小随框体缩放
                {
                    text                                                                                                    = L["name_scales_with_frame"],
                    check                                                                                                   = {
                        get                                                                                                 = function()
                            return DB().Appearance.Name.ScaleWithFrame
                        end,
                        set                                                                                                 = function(value)
                            DB().Appearance.Name.ScaleWithFrame = value
                            SendConfigChanged()
                        end
                    }
                }
                
                    -- 不允许更改颜色
                    -- submenu                                                                                                 = {
                    --     {
                    --         text                                                                                            = ENABLE,
                    --         check                                                                                           = {
                    --             get                                                                                         = function()
                    --                 return DB().Appearance.Name.FriendsNameColoring
                    --             end,
                    --             set                                                                                         = function(value)
                    --                 DB().Appearance.Name.FriendsNameColoring = value
                    --                 FireSystemEvent("UNIT_NAME_UPDATE", 'any')
                    --             end
                    --         }
                    --     },
                    --     {
                    --         text                                                                                            = L["battle_net_friend_color"],
                    --         color                                                                                           = {
                    --             get                                                                                         = function()
                    --                 return DB().Appearance.Name.BNFriendColor
                    --             end,
                    --             set                                                                                         = function(value)
                    --                 DB().Appearance.Name.BNFriendColor = value
                    --                 FireSystemEvent("UNIT_NAME_UPDATE", 'any')
                    --             end
                    --         }
                    --     },
                    --     {
                    --         text                                                                                            = L["guild_friend_color"],
                    --         color                                                                                           = {
                    --             get                                                                                         = function()
                    --                 return DB().Appearance.Name.GuildColor
                    --             end,
                    --             set                                                                                         = function(value)
                    --                 DB().Appearance.Name.GuildColor = value
                    --                 FireSystemEvent("UNIT_NAME_UPDATE", 'any')
                    --             end
                    --         }
                    --     },
                    --     {
                    --         text                                                                                            = L["friend_color"],
                    --         color                                                                                           = {
                    --             get                                                                                         = function()
                    --                 return DB().Appearance.Name.FriendColor
                    --             end,
                    --             set                                                                                         = function(value)
                    --                 DB().Appearance.Name.FriendColor = value
                    --                 FireSystemEvent("UNIT_NAME_UPDATE", 'any')
                    --             end
                    --         }
                    --     }
                    -- }
            } 
        },
        -- 单位框体背景
        {
            text                                                                                                            = L["unitframe_background"],
            submenu                                                                                                         = GetTextureMenus("Background", {
                get                                                                                                         = function()
                    return DB().Appearance.Background or DEFAULT_TEXTURE
                end,
                set                                                                                                         = function(value)
                    DB().Appearance.Background = (value ~= DEFAULT_TEXTURE and value or nil)
                    SendConfigChanged()
                end
            })
        },
        -- 光环
        {
            text                                                                                                            = L["aura"],
            submenu                                                                                                         = {
                -- 光环大小
                {
                    text                                                                                                    = L["aura_size"],
                    tiptitle                                                                                                = L["tips"],
                    tiptext                                                                                                 = L["aura_size_tips"],
                    click                                                                                                   = function()
                        local value = PickRange(L["aura_size"], 5, 15, 1, DB().Appearance.Aura.AuraSize)
                        if value then
                            DB().Appearance.Aura.AuraSize = value
                            SendConfigChanged()
                        end
                    end
                },
                -- 禁用鼠标提示
                {
                    text                                                                                                    = L["aura_disable_tooltip"],
                    tiptitle                                                                                                = L["tips"],
                    tiptext                                                                                                 = L["aura_disable_tooltip_tips"],
                    check                                                                                                   = {
                        get                                                                                                 = function()
                            return DB().Appearance.Aura.DisableTooltip
                        end,
                        set                                                                                                 = function(value)
                            DB().Appearance.Aura.DisableTooltip = value
                            SendConfigChanged()
                        end
                    }
                },
                -- 显示冷却时间
                {
                    text                                                                                                    = COUNTDOWN_FOR_COOLDOWNS_TEXT,
                    tiptitle                                                                                                = L["tips"],
                    tiptext                                                                                                 = L["aura_show_countdown_numbers_tips"],
                    check                                                                                                   = {
                        get                                                                                                 = function()
                            return DB().Appearance.Aura.ShowCountdownNumbers
                        end,
                        set                                                                                                 = function(value)
                            DB().Appearance.Aura.ShowCountdownNumbers = value
                            SendConfigChanged()
                        end
                    }
                }
            }
        },
        -- 仇恨指示器
        {
            text                                                                                                            = COMPACT_UNIT_FRAME_PROFILE_DISPLAYAGGROHIGHLIGHT,
            check                                                                                                           = {
                get                                                                                                         = function()
                    return DB().Appearance.DisplayAggroHighlight and true or false
                end,
                set                                                                                                         = function(value)
                    DB().Appearance.DisplayAggroHighlight = value
                    SendConfigChanged()
                end
            }
        },
        -- 焦点指示器
        {
            text                                                                                                            = L["show_focus_indicator"],
            check                                                                                                           = {
                get                                                                                                         = function()
                    return DB().Appearance.DisplayFocusHighlight and true or false
                end,
                set                                                                                                         = function(value)
                    DB().Appearance.DisplayFocusHighlight = value
                    SendConfigChanged()
                end
            }
        },
        -- 可驱散Debuff高亮
        {
            text                                                                                                            = L["show_dispellable_debuff_indicator"],
            tiptitle                                                                                                        = L["tips"],
            tiptext                                                                                                         = L["show_dispellable_debuff_indicator_tips"],
            check                                                                                                           = {
                get                                                                                                         = function()
                    return DB().Appearance.DisplayDispellableDebuffHighlight and true or false
                end,
                set                                                                                                         = function(value)
                    DB().Appearance.DisplayDispellableDebuffHighlight = value
                    SendConfigChanged()
                end
            }
        },
        -- 显示面板标签
        {
            text                                                                                                            = L["show_panel_label"],
            tiptitle                                                                                                        = L["tips"],
            tiptext                                                                                                         = L["show_panel_label_tips"],
            check                                                                                                           = {
                get                                                                                                         = function()
                    return DB().Appearance.DisplayPanelLabel and true or false
                end,
                set                                                                                                         = function(value)
                    DB().Appearance.DisplayPanelLabel = value
                    SendConfigChanged()
                end
            }
        },
        -- 显示宠物面板标签
        {
            text                                                                                                            = L["show_pet_panel_label"],
            check                                                                                                           = {
                get                                                                                                         = function()
                    return DB().Appearance.DisplayPetPanelLabel and true or false
                end,
                set                                                                                                         = function(value)
                    DB().Appearance.DisplayPetPanelLabel = value
                    SendConfigChanged()
                end
            }
        },
        -- 仅显示可供驱散的Debuff
        {
            text                                                                                                            = COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYDISPELLABLEDEBUFFS,
            check                                                                                                           = {
                get                                                                                                         = function()
                    return DB().Appearance.DisplayOnlyDispellableDebuffs and true or false
                end,
                set                                                                                                         = function(value)
                    DB().Appearance.DisplayOnlyDispellableDebuffs = value
                    SendConfigChanged()
                    FireSystemEvent("UNIT_AURA", "any")
                end
            }
        }
    }

    return menu
end

local function GetTemplateMenu()
    local menu = {
        {
            text                                                                                                            = L["add_template"],
            click                                                                                                           = function()
                AddCurrentConfigurationAsTemplate(Input(L["add_template"]))
            end
        },
        {
            text                                                                                                            = L["template_default_apply"],
            tiptitle                                                                                                        = L["tips"],
            tiptext                                                                                                         = L["template_default_apply_tips"],
            click                                                                                                           = function()
                if Confirm(L["template_default_apply_confirm"]) then
                    ApplyDefaultTemplate()
                end
            end
        }
    }

    for name, _ in pairs(_SVDB.Templates) do
        local templateMenu                                                                                                  = {
            text                                                                                                            = name,
            submenu                                                                                                         = {
                {
                    text                                                                                                    = L["template_apply"],
                    tiptitle                                                                                                = L["tips"],
                    tiptext                                                                                                 = L["template_apply_tips"],
                    click                                                                                                   = function()
                        if Confirm(L["template_apply_confirm"]:format(name)) then
                            ApplyTemplate(name)
                        end
                    end
                },
                {
                    text                                                                                                    = L["template_update"],
                    tiptitle                                                                                                = L["tips"],
                    tiptext                                                                                                 = L["template_update_tips"],
                    click                                                                                                   = function()
                        if Confirm(L["template_update_confirm"]:format(name)) then
                            UpdateTemplate(name)
                        end
                    end
                },
                {
                    text                                                                                                    = L["template_delete"],
                    click                                                                                                   = function()
                        if Confirm(L["template_delete_confirm"]:format(name)) then
                            DeleteTemplate(name)
                        end
                    end
                }
            }
        }

        tinsert(menu, templateMenu)
    end

    return menu
end

local function generateMenu()
    local menu = {
        {
            separator                                                                                                       = true
        },
        {
            text                                                                                                            = L["menu_title"],
            submenu                                                                                                         = {
                {
                    text                                                                                                    = L["appearance"],
                    submenu                                                                                                 = GetAppearanceMenu()
                },
                {
                    text                                                                                                    = L["block_blizzard_unitframe"],
                    tiptitle                                                                                                = L["tips"],
                    tiptext                                                                                                 = L["block_blizzard_unitframe_tips"],
                    check                                                                                                   = {
                        get                                                                                                 = function()
                            return CharDB.BlockBlizzardUnitFrames
                        end,
                        set                                                                                                 = function(value)
                            CharDB.BlockBlizzardUnitFrames = value
                            ReloadUI()
                        end
                    }
                },
                {
                    text                                                                                                    = L["template"],
                    tiptitle                                                                                                = L["tips"],
                    tiptext                                                                                                 = L["template_tips"],
                    submenu                                                                                                 = GetTemplateMenu()
                }
            }
        },
        
    }

    return menu
end

__SystemEvent__()
function ASHTOASH_OPEN_MENU(panel, menu)
    local skinMenu = generateMenu()

    for _, v in ipairs(skinMenu) do
        tinsert(menu, v)
    end
end

-------------------------------------------------
-- Template
-------------------------------------------------

function AddCurrentConfigurationAsTemplate(name)
    if not name or _SVDB.Templates[name] then
        ShowError(L["err_add_template"])
        return
    end

    local template                                                                                                          = {
        AshToAshData                                                                                                        = CharSV():GetData(),
        AshToAsh_BlizzardSkinData                                                                                           = DB():GetData()
    }
    
    _SVDB.Templates[name] = template
end

function UpdateTemplate(name)
    if not name or not _SVDB.Templates[name] then return end

    local template                                                                                                          = {
        AshToAshData                                                                                                        = CharSV():GetData(),
        AshToAsh_BlizzardSkinData                                                                                           = DB():GetData()
    }
    
    _SVDB.Templates[name] = template
end

function ApplyTemplate(name)
    if not name then return end

    local template = _SVDB.Templates[name]
    if not template then return end

    CharSV():SetData(template.AshToAshData)
    DB():SetData(template.AshToAsh_BlizzardSkinData)
    ReloadUI()
end

function DeleteTemplate(name)
    _SVDB.Templates[name] = nil
end

function ApplyDefaultTemplate()
    CharSV():SetData(_Parent.DefaultTemplate)
    DB():Reset()
    ReloadUI()
end