Scorpio "AshToAsh.BlizzardSkin.Api.Name" ""

NicknameGUIDMap = LruCache(100)

__Message__()
function ATA_BLZ_SKIN_NICKNAME(message, channel, sender, target)
    if message.guid and message.nickname then
        NicknameGUIDMap[message.guid] = message.nickname
        if DB.Appearance.Name.ShowNicknameOthers then
            FireSystemEvent("ASHTOASH_BLZ_SKIN_NICK_NAME_UPDATE", "any")
        end
    end
end

__SystemEvent__ "GROUP_ROSTER_UPDATE" "PLAYER_ENTERING_WORLD" "ASHTOASH_BLZ_SKIN_NICK_NAME_REFRESH"
function ASHTOASH_BLIZZARD_SKIN_SHOW_NICKNAME_TO_OTHERS()
    if not DB.Appearance.Name.ShowNicknameToOthers or not DB.Appearance.Name.Nickname then return end
    local channel
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        channel = "INSTANCE_CHAT"
    elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
        channel = IsInRaid() and "RIAD" or "PARTY"
    end
    if channel then
        SendAddonMessage("ATA_BLZ_SKIN_NICKNAME", { guid = UnitGUID("player"), nickname = DB.Appearance.Name.Nickname }, channel)
    end
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitName()
    return Wow.FromUnitEvent(Wow.FromEvent("UNIT_NAME_UPDATE", "GROUP_ROSTER_UPDATE", "ASHTOASH_BLZ_SKIN_NICK_NAME_UPDATE")):Next():Map(function(unit)
        -- 显示自己的昵称
        if DB.Appearance.Name.ShowNicknameOwns and DB.Appearance.Name.Nickname and UnitIsUnit("player", unit) then
            return DB.Appearance.Name.Nickname
        elseif not UnitIsUnit("player", unit) and DB.Appearance.Name.ShowNicknameOthers then
            -- 显示他人的昵称
            local guid = UnitGUID(unit)
            if guid then
                local nickname = NicknameGUIDMap[guid]
                if nickname and nickname ~= -1 then
                    return nickname
                end
            end
        end

        if DB.Appearance.Name.Style == NameStyle.PLAYERNAME_SERVER_SHORTHAND then
            return GetUnitName(unit)
        elseif DB.Appearance.Name.Style == NameStyle.PLAYERNAME_SERVER then
            return GetUnitName(unit, true)
        else
            return UnitName(unit)
        end
    end)
end