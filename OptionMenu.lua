Scorpio "AshToAsh.BlizzardSkin.OptionMenu" ""

-------------------------------------------------
-- Menu
-------------------------------------------------

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
                    disabled                                                                                                = DB.Appearance.PowerBar.Visibility ~= Visibility.SHOW_ALWAYS,
                    tiptitle                                                                                                = L["tips"],
                    tiptext                                                                                                 = L["power_bar_visibility_tips"],
                    submenu                                                                                                 = {
                        check                                                                                               = {
                            get                                                                                             = function()
                                return DB.Appearance.CastBar.Visibility
                            end,
                            set                                                                                             = function(value)
                                DB.Appearance.CastBar.Visibility = value
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
                }
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
                                return DB.Appearance.PowerBar.Visibility
                            end,
                            set                                                                                             = function(value)
                                DB.Appearance.PowerBar.Visibility = value
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
                }
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
                                return DB.Appearance.HealthBar.HealthText.Style
                            end,
                            set                                                                                             = function(value)
                                DB.Appearance.HealthBar.HealthText.Style = value
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
                                return DB.Appearance.HealthBar.HealthText.TextFormat
                            end,
                            set                                                                                             = function(value)
                                DB.Appearance.HealthBar.HealthText.TextFormat = value
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
                -- 生命值大小随框体缩放
                {
                    text                                                                                                    = L["name_scales_with_frame"],
                    check                                                                                                   = {
                        get                                                                                                 = function()
                            return DB.Appearance.HealthBar.HealthText.ScaleWithFrame
                        end,
                        set                                                                                                 = function(value)
                            DB.Appearance.HealthBar.HealthText.ScaleWithFrame = value
                            SendConfigChanged()
                        end
                    }
                }
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
                                return DB.Appearance.Name.Style
                            end,
                            set                                                                                             = function(value)
                                DB.Appearance.Name.Style = value
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
                            text                                                                                            = DB.Appearance.Name.Nickname and L["nick_name_format"]:format(DB.Appearance.Name.Nickname) or L["nick_name_setting"],
                            tiptitle                                                                                        = L["tips"],
                            tiptext                                                                                         = L["nick_name_setting"],
                            click                                                                                           = function()
                                local nickname = Input(L["nick_name_setting"])
                                if nickname and strlen(nickname) > 25 then
                                    ShowError(L["err_nickname_too_long"])
                                    return
                                end
                                DB.Appearance.Name.Nickname = nickname
                                FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_UPDATE", 'any')
                                FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_REFRESH", 'any')
                            end
                        },
                        -- 显示自己的昵称
                        {
                            text                                                                                            = L["show_nick_name_owns"],
                            check                                                                                           = {
                                get                                                                                         = function()
                                    return DB.Appearance.Name.ShowNicknameOwns
                                end,
                                set                                                                                         = function(value)
                                    DB.Appearance.Name.ShowNicknameOwns = value
                                    FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_UPDATE", 'any')
                                end
                            }
                        },
                        -- 显示他人的昵称
                        {
                            text                                                                                            = L["show_nick_name_others"],
                            check                                                                                           = {
                                get                                                                                         = function()
                                    return DB.Appearance.Name.ShowNicknameOthers
                                end,
                                set                                                                                         = function(value)
                                    DB.Appearance.Name.ShowNicknameOthers = value
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
                                    return DB.Appearance.Name.ShowNicknameToOthers
                                end,
                                set                                                                                         = function(value)
                                    DB.Appearance.Name.ShowNicknameToOthers = value
                                    FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_REFRESH", 'any')
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
                            return DB.Appearance.Name.FriendsNameColoring
                        end,
                        set                                                                                                 = function(value)
                            DB.Appearance.Name.FriendsNameColoring = value
                            FireSystemEvent("UNIT_NAME_UPDATE", 'any')
                        end
                    }
                },
                -- 名字大小随框体缩放
                {
                    text                                                                                                    = L["name_scales_with_frame"],
                    check                                                                                                   = {
                        get                                                                                                 = function()
                            return DB.Appearance.Name.ScaleWithFrame
                        end,
                        set                                                                                                 = function(value)
                            DB.Appearance.Name.ScaleWithFrame = value
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
                    --                 return DB.Appearance.Name.FriendsNameColoring
                    --             end,
                    --             set                                                                                         = function(value)
                    --                 DB.Appearance.Name.FriendsNameColoring = value
                    --                 FireSystemEvent("UNIT_NAME_UPDATE", 'any')
                    --             end
                    --         }
                    --     },
                    --     {
                    --         text                                                                                            = L["battle_net_friend_color"],
                    --         color                                                                                           = {
                    --             get                                                                                         = function()
                    --                 return DB.Appearance.Name.BNFriendColor
                    --             end,
                    --             set                                                                                         = function(value)
                    --                 DB.Appearance.Name.BNFriendColor = value
                    --                 FireSystemEvent("UNIT_NAME_UPDATE", 'any')
                    --             end
                    --         }
                    --     },
                    --     {
                    --         text                                                                                            = L["guild_friend_color"],
                    --         color                                                                                           = {
                    --             get                                                                                         = function()
                    --                 return DB.Appearance.Name.GuildColor
                    --             end,
                    --             set                                                                                         = function(value)
                    --                 DB.Appearance.Name.GuildColor = value
                    --                 FireSystemEvent("UNIT_NAME_UPDATE", 'any')
                    --             end
                    --         }
                    --     },
                    --     {
                    --         text                                                                                            = L["friend_color"],
                    --         color                                                                                           = {
                    --             get                                                                                         = function()
                    --                 return DB.Appearance.Name.FriendColor
                    --             end,
                    --             set                                                                                         = function(value)
                    --                 DB.Appearance.Name.FriendColor = value
                    --                 FireSystemEvent("UNIT_NAME_UPDATE", 'any')
                    --             end
                    --         }
                    --     }
                    -- }
            } 
        },
        -- 仇恨指示器
        {
            text                                                                                                            = COMPACT_UNIT_FRAME_PROFILE_DISPLAYAGGROHIGHLIGHT,
            check                                                                                                           = {
                get                                                                                                         = function()
                    return DB.Appearance.DisplayAggroHighlight and true or false
                end,
                set                                                                                                         = function(value)
                    DB.Appearance.DisplayAggroHighlight = value
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
                    return DB.Appearance.DisplayPanelLabel and true or false
                end,
                set                                                                                                         = function(value)
                    DB.Appearance.DisplayPanelLabel = value
                    SendConfigChanged()
                end
            }
        },
        -- 显示宠物面板标签
        {
            text                                                                                                            = L["show_pet_panel_label"],
            check                                                                                                           = {
                get                                                                                                         = function()
                    return DB.Appearance.DisplayPetPanelLabel and true or false
                end,
                set                                                                                                         = function(value)
                    DB.Appearance.DisplayPetPanelLabel = value
                    SendConfigChanged()
                end
            }
        },
        -- 仅显示可供驱散的Debuff
        {
            text                                                                                                            = COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYDISPELLABLEDEBUFFS,
            check                                                                                                           = {
                get                                                                                                         = function()
                    return DB.Appearance.DisplayOnlyDispellableDebuffs and true or false
                end,
                set                                                                                                         = function(value)
                    DB.Appearance.DisplayOnlyDispellableDebuffs = value
                    SendConfigChanged()
                    FireSystemEvent("UNIT_AURA", "any")
                end
            }
        },
    }

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
                            return DB.BlockBlizzardUnitFrames
                        end,
                        set                                                                                                 = function(value)
                            DB.BlockBlizzardUnitFrames = value
                            ReloadUI()
                        end
                    }
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

    SendConfigChanged()
end

-------------------------------------------------
-- Config Panel
-------------------------------------------------

-- ConfigPanel                 = Dialog("AshToAsh_BlzSkinConfigDialog")
-- ConfigPanel:Hide()



-- Style[ConfigPanel]                                      = {
    
--     size                                                = Size(640, 560),

--     Resizer                                             = {
--         visible                                         = false
--     },

--     Header                                              = {
--         text                                            = L["menu_title"]
--     },


-- }