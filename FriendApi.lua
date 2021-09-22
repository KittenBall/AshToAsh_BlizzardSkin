Scorpio "AshToAsh.BlizzardSkin.Api.Friend" ""

FriendList = {}
BNFriendList = {}

if Scorpio.IsRetail then
    __SecureHook__()
    function FriendsList_Update()
        -- 获取好友guid
        wipe(FriendList)
        for i = 1, C_FriendList.GetNumFriends() do
            local info = C_FriendList.GetFriendInfoByIndex(i)
            if info.guid then
                tinsert(FriendList, info.guid)
            end
        end

        -- 获取战网好友GUID
        wipe(BNFriendList)
        for i = 1, BNGetNumFriends() do
            for j = 1, C_BattleNet.GetFriendNumGameAccounts(i) do
                local game = C_BattleNet.GetFriendGameAccountInfo(i, j)
                if game and game.wowProjectID == WOW_PROJECT_ID and game.playerGuid then
                    tinsert(BNFriendList, game.playerGuid)
                end
            end
        end
    end
else
    __SecureHook__()
    function FriendsList_Update()
        -- 获取好友guid
        wipe(FriendList)
        for i = 1, C_FriendList.GetNumFriends() do
            local info = C_FriendList.GetFriendInfoByIndex(i)
            if info.guid then
                tinsert(FriendList, info.guid)
            end
        end

        -- 获取战网好友GUID
        wipe(BNFriendList)
        for i = 1, BNGetNumFriends() do
            for j = 1, BNGetNumFriendGameAccounts(i) do
                local _, _, client, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, playerGuid, wowProjectID = BNGetFriendGameAccountInfo(i, j)
                if client == BNET_CLIENT_WOW and wowProjectID == WOW_PROJECT_ID and playerGuid then
                    tinsert(BNFriendList, playerGuid)
                end
            end
        end
    end
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitNameColor()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_NAME_UPDATE", "GROUP_ROSTER_UPDATE")):Next():Map(function(unit)
        if not DB.Appearance.Name.FriendsNameColoring or  not UnitIsPlayer(unit) or UnitIsUnit("player", unit) then return Color.WHITE end
        local guid = UnitGUID(unit)
        if tContains(BNFriendList, guid) then
            return Color.BATTLENET
        elseif tContains(FriendList, guid) then
            return Color.NORMAL
        elseif UnitIsInMyGuild(unit) then
            return GuildColor
        else
            return Color.WHITE
        end
    end)
end