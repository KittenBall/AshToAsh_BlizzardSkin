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
        Style[mask]             = {
            frameLevel          = 8,
            frameStrata         = "DIALOG",

            Label               = {
                text            = L["panel_mask_tips"],
                fontObject      = GameFontWhiteTiny,
                justifyH        = "CENTER",
                justifyV        = "TOP",
                location        = {
                    Anchor("TOPLEFT", 8, -8),
                    Anchor("BOTTOMRIGHT", -8, 8)
                }
            }
        }
    end

    RECYCLE_MASKS.OnInit = RECYCLE_MASKS.OnInit + OnInit

    _SVDB = SVManager("AshToAsh_BlizzardSkin_DB", "AshToAsh_BlizzardSkin_CharDB")
    _SVDB:SetDefault{
        Templates                                                                                                           = {}
    }

    CharDB = _SVDB.Char
    CharDB:SetDefault{
        BlockBlizzardUnitFrames                                                                                             = true
    }

    DB():SetDefault{
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
                    TextFormat                                                                                              = HealthTextFormat.KILO,
                    ScaleWithFrame                                                                                          = false
                },
            },
            -- 名字
            Name                                                                                                            = {
                ScaleWithFrame                                                                                              = false,
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
            -- 仅显示可供驱散的Debuff
            DisplayOnlyDispellableDebuffs                                                                                   = false,
        }
    }
    
    -- 初始化推送值
    Delay(3, SendConfigChanged)
end

function OnSpecChanged()
    SendConfigChanged()

    -- 触发一些配置更改
    FireSystemEvent("UNIT_HEALTH", 'any')
    FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_UPDATE", 'any')
    FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_REFRESH", 'any')
    FireSystemEvent("UNIT_NAME_UPDATE", 'any')
end

function SendConfigChanged()
    FireSystemEvent("AshToAsh_Blizzard_Skin_Config_Changed")
end

__Static__() __AutoCache__()
function AshBlzSkinApi.OnConfigChanged()
    return Wow.FromUnitEvent(Wow.FromEvent("AshToAsh_Blizzard_Skin_Config_Changed"):Map("=> 'any'"))
end

function ShowError(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.0, 0.0, 1, 4)
end

if Scorpio.IsRetail then
    function DB()
        return _SVDB.Char.Spec
    end
else
    function DB()
        return _SVDB.Char
    end
end

-------------------------------------------------
-- Classic Compact
-------------------------------------------------
if Scorpio.IsRetail then return end
GetThreatStatusColor = _G.GetThreatStatusColor or function (index) if index == 3 then return 1, 0, 0 elseif index == 2 then return 1, 0.6, 0 elseif index == 1 then return 1, 1, 0.47 else return 0.69, 0.69, 0.69 end end
UnitTreatAsPlayerForDisplay = Toolset.fakefunc