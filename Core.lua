Scorpio "AshToAsh.BlizzardSkin" ""

namespace "AshToAsh.Skin.Blizzard"

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

function OnLoad()
    DB = SVManager("AshToAsh_BlizzardSkin_DB")
    DB:SetDefault{
        Appearance                                                                                                          = {
            CastBar                                                                                                         = {
                Visibility                                                                                                  = Visibility.SHOW_ONLY_PARTY
            }
        }
    }

    -- 初始化推送值
    OnConfigChanged()
end


function OnConfigChanged()
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
        }
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