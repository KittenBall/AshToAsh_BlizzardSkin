Scorpio "AshToAsh.BlizzardSkin" ""

namespace "AshToAsh.Skin.Blizzard"

import "Scorpio.Secure.UnitFrame"

L = _Locale

SKIN_NAME = "AshToAsh.BlizzardSkin"
Style.RegisterSkin(SKIN_NAME)

__Sealed__()
interface "AshBlzSkinApi" {}

class "LruCache"(function(_ENV)

    __Arguments__(NaturalNumber)
    function __new(_, capacity)
        if capacity <= 0 then
            capacity = 1
        end

        local head = {}
        local tail = {}
        head.next = tail
        tail.pre = head
        return {Capacity = capacity, Cache = {}, Head = head, Tail = tail, CacheSize = 0}
    end

    __Arguments__(NEString)
    function __index(self, key)
        local cache = self.Cache
        local node = cache[key]
        if node then
            node.pre.next = node.next
            node.next.pre = node.pre

            self.Tail.pre.next = node
            node.next = self.Tail
            node.pre = self.Tail.pre
            self.Tail.pre = node
            return node.value
        end
        return -1
    end

    __Arguments__{NEString, Any/nil}
    function __newindex(self, key, value)
        if self[key] ~= -1 then
            self.Tail.pre.value = value
        else
            if self.CacheSize == self.Capacity then
                self.Cache[self.Head.next.key] = nil
                self.CacheSize = self.CacheSize - 1
                self.Head.next = self.Head.next.next
                self.Head.next.pre = self.Head 
            end

            local node  = {}
            node.key = key
            node.value = value
            
            self.Tail.pre.next = node
            node.pre = self.Tail.pre
            node.next = self.Tail
            self.Tail.pre = node

            self.Cache[key] = node
            self.CacheSize = self.CacheSize + 1
        end
    end
end)

__Sealed__() __AutoIndex__()
enum "Visibility" {
    "HIDE",
    "SHOW_ONLY_PARTY",
    "SHOW_ALWAYS"
}

__Sealed__() __AutoIndex__()
enum "HealthTextStyle" {
    "NONE",
    "HEALTH",
    "LOSTHEALTH",
    "PERCENT"
}

__Sealed__() __AutoIndex__()
enum "HealthTextFormat" {
    "NORMAL",
    "KILO", -- 千
    "TEN_THOUSAND" -- 万
}

__Sealed__() __AutoIndex__()
enum "NameStyle" {
    "PLAYERNAME",
    "PLAYERNAME_SERVER_SHORTHAND",
    "PLAYERNAME_SERVER"
}

GuildColor = Color(0.25, 1, 0.25, 1)

function OnLoad()
    -- make mask frame strata lower
    local function OnInit(self, mask)
        mask:InstantApplyStyle()
        mask:SetFrameStrata("DIALOG")
        mask:SetFrameLevel(8)
    end

    RECYCLE_MASKS.OnInit = RECYCLE_MASKS.OnInit + OnInit

    DB = SVManager("AshToAsh_BlizzardSkin_DB", "AshToAsh_BlizzardSkin_CharDB").Char
    DB:SetDefault{
        Appearance                                                                                                          = {
            -- 施法条
            CastBar                                                                                                         = {
                Visibility                                                                                                  = Visibility.SHOW_ONLY_PARTY
            },
            -- 能量条
            PowerBar                                                                                                        = {
                Visibility                                                                                                  = Visibility.SHOW_ALWAYS
            },
            -- 仇恨高亮
            DisplayAggroHighlight                                                                                           = true,
            -- 生命条
            HealthBar                                                                                                       = {
                -- 生命值文本
                HealthText                                                                                                  = {
                    Style                                                                                                   = HealthTextStyle.NONE,
                    TextFormat                                                                                              = HealthTextFormat.KILO
                },
            },
            -- 名字
            Name                                                                                                            = {
                Style                                                                                                       = NameStyle.PLAYERNAME_SERVER_SHORTHAND,
                Nickname                                                                                                    = nil,
                ShowNicknameOwns                                                                                            = true,
                ShowNicknameOthers                                                                                          = true,
                ShowNicknameToOthers                                                                                        = true,
                FriendsNameColoring                                                                                         = true,
                GuildColor                                                                                                  = GuildColor,
                FriendColor                                                                                                 = Color.NORMAL,
                BNFriendColor                                                                                               = Color.BATTLENET
            },
            -- 显示面板标签
            DisplayPanelLabel                                                                                               = true,
            -- 显示宠物面板标签
            DisplayPetPanelLabel                                                                                            = true,
        }
    }

    -- 初始化推送值
    Delay(3, SendConfigChanged)
end

function SendConfigChanged()
    FireSystemEvent("AshToAsh_Blizzard_Skin_Config_Changed")
end

__Static__() __AutoCache__()
function AshBlzSkinApi.OnConfigChanged()
    return Wow.FromUnitEvent(Wow.FromEvent("AshToAsh_Blizzard_Skin_Config_Changed"):Map("=> 'any'"))
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
                }
            }
        }
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

function ShowError(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.0, 0.0, 1, 4)
end

-------------------------------------------------
-- Classic Compact
-------------------------------------------------
if Scorpio.IsRetail then return end
GetThreatStatusColor = _G.GetThreatStatusColor or function (index) if index == 3 then return 1, 0, 0 elseif index == 2 then return 1, 0.6, 0 elseif index == 1 then return 1, 1, 0.47 else return 0.69, 0.69, 0.69 end end
UnitTreatAsPlayerForDisplay = Toolset.fakefunc