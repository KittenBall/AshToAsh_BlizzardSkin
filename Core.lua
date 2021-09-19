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

enum "HealthTextFormat" {
    "NORMAL",
    "KILO", -- 千
    "TEN_THOUSAND" -- 万
}

function OnLoad()
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
            -- 生命值
            Health                                                                                                          = {
                Style                                                                                                       = HealthTextStyle.NONE,
                TextFormat                                                                                                  = HealthTextFormat.KILO
            }
        }
    }

    -- 初始化推送值
    OnConfigChanged("ALL")
end

function OnConfigChanged(type)
    FireSystemEvent("AshToAsh_Blizzard_Skin_Config_Changed", type)
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
                                OnConfigChanged()
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
                                OnConfigChanged()
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
                                return DB.Appearance.Health.Style
                            end,
                            set                                                                                             = function(value)
                                DB.Appearance.Health.Style = value
                                OnConfigChanged("HealthTextStyle")
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
                                return DB.Appearance.Health.TextFormat
                            end,
                            set                                                                                             = function(value)
                                DB.Appearance.Health.TextFormat = value
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
        -- 仇恨指示器
        {
            text                                                                                                            = COMPACT_UNIT_FRAME_PROFILE_DISPLAYAGGROHIGHLIGHT,
            check                                                                                                           = {
                get                                                                                                         = function()
                    return DB.Appearance.DisplayAggroHighlight and true or false
                end,
                set                                                                                                         = function(value)
                    DB.Appearance.DisplayAggroHighlight = value
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
end

-------------------------------------------------
-- Classic Compact
-------------------------------------------------
if Scorpio.IsRetail then return end
GetThreatStatusColor = _G.GetThreatStatusColor or function (index) if index == 3 then return 1, 0, 0 elseif index == 2 then return 1, 0.6, 0 elseif index == 1 then return 1, 1, 0.47 else return 0.69, 0.69, 0.69 end end
UnitTreatAsPlayerForDisplay = Toolset.fakefunc