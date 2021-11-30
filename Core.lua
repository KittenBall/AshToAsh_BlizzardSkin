Scorpio "AshToAsh.BlizzardSkin" ""

namespace "AshToAsh.Skin.Blizzard"

import "Scorpio.Secure.UnitFrame"

L = _Locale
_Core = _M

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

GuildColor          = Color(0.25, 1, 0.25, 1)
-- Default Name Label Font
NameFont, NameFontSize = GameFontHighlightSmall:GetFont()
-- Default Health Label Font
HealthLabelFont, HealthLabelFontSize = SystemFont_Small:GetFont()
-- Default CastBar Label Font
CastBarLabelFont, CastBarLabelFontSize = GameFontWhiteTiny2:GetFont()

function OnLoad()
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
                Visibility                                                                                                  = Visibility.SHOW_ONLY_PARTY,
                Texture                                                                                                     = nil,
                Font                                                                                                        = CastBarLabelFont,
                FontSize                                                                                                    = CastBarLabelFontSize,
                FontOutline                                                                                                 = "NONE",
                FontMonochrome                                                                                              = false
            },
            -- 能量条
            PowerBar                                                                                                        = {
                Visibility                                                                                                  = Visibility.SHOW_ALWAYS,
                Texture                                                                                                     = nil,
                Background                                                                                                  = nil
            },
            -- 仇恨高亮
            DisplayAggroHighlight                                                                                           = true,
            -- 焦点高亮
            DisplayFocusHighlight                                                                                           = true,
            -- 可驱散Debuff高亮
            DisplayDispellableDebuffHighlight                                                                               = true,
            -- 生命条
            HealthBar                                                                                                       = {
                -- 生命值文本
                HealthText                                                                                                  = {
                    Style                                                                                                   = HealthTextStyle.NONE,
                    TextFormat                                                                                              = HealthTextFormat.KILO,
                    ScaleWithFrame                                                                                          = false,
                    Font                                                                                                    = HealthLabelFont,
                    FontSize                                                                                                = HealthLabelFontSize,
                    FontOutline                                                                                             = "NONE",
                    FontMonochrome                                                                                          = false
                },
                Texture                                                                                                     = nil,
            },
            -- 光环
            Aura                                                                                                            = {
                AuraSize                                                                                                    = 11,
                DisableTooltip                                                                                              = false,
                ShowCountdownNumbers                                                                                        = false
            },
            Background                                                                                                      = nil,
            -- 名字
            Name                                                                                                            = {
                ScaleWithFrame                                                                                              = false,
                Style                                                                                                       = NameStyle.PLAYERNAME_SERVER_SHORTHAND,
                Nickname                                                                                                    = nil,
                ShowNicknameOwns                                                                                            = true,
                ShowNicknameOthers                                                                                          = true,
                ShowNicknameToOthers                                                                                        = true,
                GuildColor                                                                                                  = GuildColor,
                FriendColor                                                                                                 = Color.NORMAL,
                BNFriendColor                                                                                               = Color.BATTLENET,
                Font                                                                                                        = NameFont,
                FontSize                                                                                                    = NameFontSize,
                FontOutline                                                                                                 = "NONE",
                FontMonochrome                                                                                              = false
            },
            -- 显示面板标签
            DisplayPanelLabel                                                                                               = true,
            -- 显示宠物面板标签
            DisplayPetPanelLabel                                                                                            = true,
            -- 仅显示可供驱散的Debuff
            DisplayOnlyDispellableDebuffs                                                                                   = false
        }
    }
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
    FireSystemEvent("ASHTOASH_BLIZZARD_SKIN_CONFIG_CHANGED")
end

__Static__() __AutoCache__()
function AshBlzSkinApi.OnConfigChanged()
    return Wow.FromUnitEvent(Wow.FromEvent("ASHTOASH_BLIZZARD_SKIN_CONFIG_CHANGED"):Map("=> 'any'"))
end

EnlargeBuffList        = {}

__SystemEvent__()
function ASHTOASH_CONFIG_CHANGED()
    wipe(EnlargeBuffList)
    if _AuraPriority then
        for _, spellId in ipairs(_AuraPriority) do
            EnlargeBuffList[spellId] = true
        end
    end
end

function ShowError(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.0, 0.0, 1, 4)
end

function GetLibSharedMedia()
    if not LibSharedMedia then
        if _G.LibStub then
            LibSharedMedia = _G.LibStub("LibSharedMedia-3.0", true)
        end
    end
    return LibSharedMedia
end

function GetLibSharedMediaTexture(type, name)
    if not name then return end
    
    if GetLibSharedMedia() then
        if type == "StatusBar" then
            type = LibSharedMedia.MediaType.STATUSBAR
        elseif type == "Background" then
            type = LibSharedMedia.MediaType.BACKGROUND
        end

        return LibSharedMedia:Fetch(type, name, true)
    end
end

function GetLibSharedMediaFont(name)
    if not name then return end

    if GetLibSharedMedia() then
        return LibSharedMedia:Fetch(LibSharedMedia.MediaType.FONT, name, true)
    end
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
--[===[@non-version-retail@
GetThreatStatusColor = _G.GetThreatStatusColor or function (index) if index == 3 then return 1, 0, 0 elseif index == 2 then return 1, 0.6, 0 elseif index == 1 then return 1, 1, 0.47 else return 0.69, 0.69, 0.69 end end
UnitTreatAsPlayerForDisplay = Toolset.fakefunc
--@end-non-version-retail@]===]