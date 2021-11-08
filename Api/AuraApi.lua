Scorpio "AshToAsh.BlizzardSkin.Api.Aura" ""

UI.Property             {
    name                = "AuraEngine",
    type                = String,
    require             = UnitFrame,
    set                 = Toolset.fakefunc
}

function OnEnable()
    PlayerClass = UnitClassBase("player")
    AuraPool = Recycle()
    AuraPool.OnPush = function(self, obj) wipe(obj) end
end

__Static__() __AutoCache__()
function AshBlzSkinApi.AuraEngine()
    return Wow.UnitAura():Map(ParseAura)
end

local function GetAuraData(unit, index, filter)
    local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll = UnitAura(unit, index, filter)
    local data = AuraPool()
    data.Index = index
    data.Name = name
    data.Icon = icon
    data.Count = count
    data.DebuffType = dispelType
    data.Duration = duration
    data.ExpirationTime = expirationTime
    data.Stealeable = isStealable and not UnitIsUnit(unit, "player")
    data.Caster = source
    data.SpellID = spellId
    data.IsBossAura = isBossDebuff
    data.CasterByPlayer = castByPlayer
    data.Filter = filter

    return data
end

function ParseAura(unit)
    ParseAuraStart()

    local index = 1
    while true do
        local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll = UnitBuff(unit, index)
        if not name then
            break
        end

        CheckBuff(unit, index, "HELPFUL", name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
        CheckBossAura(unit, index, "HELPFUL", name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
        CheckClassBuff(unit, index, "HELPFUL", name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
        CheckEnlargeBuff(unit, index, "HELPFUL", name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)

        index = index + 1
    end

    index = 1
    while true do
        local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll = UnitDebuff(unit, index)
        if not name then
            break
        end
        
        CheckBossAura(unit, index, "HARMFUL", name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
        CheckEnlargeDebuff(unit, index, "HARMFUL", name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)

        index = index + 1
    end

    -- index = 1
    -- while true do
    --     local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll = UnitDebuff(unit, index, "RAID")
    --     if not name then
    --         break
    --     end

    --     CheckDispellDebuff(unit, name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)

    --     index = index + 1
    -- end

    ParseAuraEnd(unit)
end

local bossAuraFlag = false
local classBuffFlag = false
local enlargeDebuffFlag = false
local enlargeBuffFlag = false

function ParseAuraStart()
    bossAuraFlag = false
    classBuffFlag = false
    enlargeDebuffFlag = false
    enlargeBuffFlag = false
    CheckBuffStart()
end

function ParseAuraEnd(unit)
    SendBossAuraData(unit)
    SendClassBuffData(unit)
    SendEnlargeDebuffData(unit)
    SendEnlargeBuffData(unit)
    SendBuffData(unit)
end

-------------------------------------------------
-- Boss aura
-------------------------------------------------

local bossAuraSubject = BehaviorSubject()
local bossDebuffData = {}
function CheckBossAura(unit, index, filter, name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
    if not bossAuraFlag then
        if isBossDebuff and not _EnlargeDebuffList[spellID] then
            bossAuraFlag = true
            bossDebuffData.Index = index
            bossDebuffData.Name = name
            bossDebuffData.Icon = icon
            bossDebuffData.Count = count
            bossDebuffData.DebuffType = dispelType
            bossDebuffData.Duration = duration
            bossDebuffData.ExpirationTime = expirationTime
            bossDebuffData.Stealeable = isStealable and not UnitIsUnit(unit, "player")
            bossDebuffData.Caster = source
            bossDebuffData.SpellID = spellId
            bossDebuffData.IsBossAura = isBossDebuff
            bossDebuffData.CasterByPlayer = castByPlayer
            bossDebuffData.Filter = filter
        end
    end
end

function SendBossAuraData(unit)
    bossAuraSubject:OnNext(unit, bossAuraFlag and bossDebuffData or nil)
end

-- 是否有Boss给的Aura
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitBossAura()
    return Wow.FromUnitEvent(bossAuraSubject):Map(function(unit, bossDebuffData)
        return bossDebuffData and true or false
    end)
end

-- Boss debuff
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitBossDebuff()
    local data = {}
    return Wow.FromUnitEvent(bossAuraSubject):Map(function(unit, bossDebuffData)
        if bossDebuffData then
            data.Unit = unit
            data.Index = bossDebuffData.Index
            data.Name = bossDebuffData.Name
            data.Icon = bossDebuffData.Icon
            data.Count = bossDebuffData.Count
            data.DebuffType = bossDebuffData.DebuffType
            data.Duration = bossDebuffData.Duration
            data.ExpirationTime = bossDebuffData.ExpirationTime
            data.Stealeable = bossDebuffData.Stealeable
            data.Caster = bossDebuffData.Caster
            data.SpellID = bossDebuffData.SpellID
            data.IsBossAura = bossDebuffData.IsBossAura
            data.CasterByPlayer = bossDebuffData.CasterByPlayer
            data.Filter = bossDebuffData.Filter
            return data
        end
    end)
end

-------------------------------------------------
-- Class buff
-------------------------------------------------

local classBuffSubject = BehaviorSubject()
local classBuffData = {}
function CheckClassBuff(unit, index, filter, name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
    if not classBuffFlag then
        if _ClassBuffList[name] or _ClassBuffList[spellId] then
            classBuffFlag = true
            classBuffData.Index = index
            classBuffData.Name = name
            classBuffData.Icon = icon
            classBuffData.Count = count
            classBuffData.DebuffType = dispelType
            classBuffData.Duration = duration
            classBuffData.ExpirationTime = expirationTime
            classBuffData.Stealeable = isStealable and not UnitIsUnit(unit, "player")
            classBuffData.Caster = source
            classBuffData.SpellID = spellId
            classBuffData.IsBossAura = isBossDebuff
            classBuffData.CasterByPlayer = castByPlayer
            classBuffData.Filter = filter
        end
    end
end

function SendClassBuffData(unit)
    classBuffSubject:OnNext(unit, classBuffFlag and classBuffData or nil)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitClassBuff()
    local data = {}
    return Wow.FromUnitEvent(classBuffSubject):Map(function(unit, classBuffData)
        if classBuffData then
            data.Unit = unit
            data.Index = classBuffData.Index
            data.Name = classBuffData.Name
            data.Icon = classBuffData.Icon
            data.Count = classBuffData.Count
            data.DebuffType = classBuffData.DebuffType
            data.Duration = classBuffData.Duration
            data.ExpirationTime = classBuffData.ExpirationTime
            data.Stealeable = classBuffData.Stealeable
            data.Caster = classBuffData.Caster
            data.SpellID = classBuffData.SpellID
            data.IsBossAura = classBuffData.IsBossAura
            data.CasterByPlayer = classBuffData.CasterByPlayer
            data.Filter = classBuffData.Filter
            return data
        end
    end)
end

-------------------------------------------------
-- Enlarge debuff
-------------------------------------------------

local enlargeDebuffSubject = BehaviorSubject()
local enlargeDebuffData = {}
function CheckEnlargeDebuff(unit, index, filter, name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
    if not enlargeDebuffFlag then
        if _EnlargeDebuffList[spellId] then
            enlargeDebuffFlag = true
            enlargeDebuffData.Index = index
            enlargeDebuffData.Name = name
            enlargeDebuffData.Icon = icon
            enlargeDebuffData.Count = count
            enlargeDebuffData.DebuffType = dispelType
            enlargeDebuffData.Duration = duration
            enlargeDebuffData.ExpirationTime = expirationTime
            enlargeDebuffData.Stealeable = isStealable and not UnitIsUnit(unit, "player")
            enlargeDebuffData.Caster = source
            enlargeDebuffData.SpellID = spellId
            enlargeDebuffData.IsBossAura = isBossDebuff
            enlargeDebuffData.CasterByPlayer = castByPlayer
            enlargeDebuffData.Filter = filter
        end
    end
end

function SendEnlargeDebuffData(unit)
    enlargeDebuffSubject:OnNext(unit, enlargeDebuffFlag and enlargeDebuffData or nil)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitEnlargeDebuff()
    local data = {}
    return Wow.FromUnitEvent(enlargeDebuffSubject):Map(function(unit, enlargeDebuffData)
        if enlargeDebuffData then
            data.Unit = unit
            data.Index = enlargeDebuffData.Index
            data.Name = enlargeDebuffData.Name
            data.Icon = enlargeDebuffData.Icon
            data.Count = enlargeDebuffData.Count
            data.DebuffType = enlargeDebuffData.DebuffType
            data.Duration = enlargeDebuffData.Duration
            data.ExpirationTime = enlargeDebuffData.ExpirationTime
            data.Stealeable = enlargeDebuffData.Stealeable
            data.Caster = enlargeDebuffData.Caster
            data.SpellID = enlargeDebuffData.SpellID
            data.IsBossAura = enlargeDebuffData.IsBossAura
            data.CasterByPlayer = enlargeDebuffData.CasterByPlayer
            data.Filter = enlargeDebuffData.Filter
            return data
        end
    end)
end

-------------------------------------------------
-- Enlarge buff
-------------------------------------------------

local enlargeBuffSubject = BehaviorSubject()
local enlargeBuffData = {}
function CheckEnlargeBuff(unit, index, filter, name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
    if not enlargeBuffFlag then
        if EnlargeBuffList[spellId] then
            enlargeBuffFlag = true
            enlargeBuffData.Index = index
            enlargeBuffData.Name = name
            enlargeBuffData.Icon = icon
            enlargeBuffData.Count = count
            enlargeBuffData.DebuffType = dispelType
            enlargeBuffData.Duration = duration
            enlargeBuffData.ExpirationTime = expirationTime
            enlargeBuffData.Stealeable = isStealable and not UnitIsUnit(unit, "player")
            enlargeBuffData.Caster = source
            enlargeBuffData.SpellID = spellId
            enlargeBuffData.IsBossAura = isBossDebuff
            enlargeBuffData.CasterByPlayer = castByPlayer
            enlargeBuffData.Filter = filter
        end
    end
end

function SendEnlargeBuffData(unit)
    enlargeBuffSubject:OnNext(unit, enlargeBuffFlag and enlargeBuffData or nil)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitEnlargeBuff()
    local data = {}
    return Wow.FromUnitEvent(enlargeBuffSubject):Map(function(unit, enlargeBuffData)
        if enlargeBuffData then
            data.Unit = unit
            data.Index = enlargeBuffData.Index
            data.Name = enlargeBuffData.Name
            data.Icon = enlargeBuffData.Icon
            data.Count = enlargeBuffData.Count
            data.DebuffType = enlargeBuffData.DebuffType
            data.Duration = enlargeBuffData.Duration
            data.ExpirationTime = enlargeBuffData.ExpirationTime
            data.Stealeable = enlargeBuffData.Stealeable
            data.Caster = enlargeBuffData.Caster
            data.SpellID = enlargeBuffData.SpellID
            data.IsBossAura = enlargeBuffData.IsBossAura
            data.CasterByPlayer = enlargeBuffData.CasterByPlayer
            data.Filter = enlargeBuffData.Filter
            return data
        end
    end)
end

-------------------------------------------------
-- Buff
-------------------------------------------------

local buffSubjects = {}
local buffCount = 3

for i = 1, buffCount do
    local subject = BehaviorSubject()
    tinsert(buffSubjects, subject)

    __Static__() __AutoCache__()
    AshBlzSkinApi["UnitBuff"..i] = function()
        local data = {}
        return Wow.FromUnitEvent(subject):Map(function(unit, buffData)
            if buffData then
                data.Unit = unit
                data.Index = buffData.Index
                data.Name = buffData.Name
                data.Icon = buffData.Icon
                data.Count = buffData.Count
                data.DebuffType = buffData.DebuffType
                data.Duration = buffData.Duration
                data.ExpirationTime = buffData.ExpirationTime
                data.Stealeable = buffData.Stealeable
                data.Caster = buffData.Caster
                data.SpellID = buffData.SpellID
                data.IsBossAura = buffData.IsBossAura
                data.CasterByPlayer = buffData.CasterByPlayer
                data.Filter = buffData.Filter

                AuraPool(buffData)
                return data
            end
        end)
    end
end

if Scorpio.IsRetail then
    local shouldDisplayBuff     = function(unitCaster, spellId, canApplyAura)
        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
        
        if ( hasCustom ) then
            return showForMySpec or (alwaysShowMine and (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle"))
        else
            return (unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellId)
        end
    end

    local buffs = {}

    function CheckBuffStart()
        wipe(buffs)
    end

    function CheckBuff(unit, index, filter, name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
        if #buffs >= buffCount then return end

        if not _AuraBlackList[spellID] and not (_ClassBuffList[name] or _ClassBuffList[spellID]) and not EnlargeBuffList[spellID] then
            if shouldDisplayBuff(source, spellId, canApplyAura) and not isBossDebuff then
                tinsert(buffs, index)
            end
        end
    end

    function SendBuffData(unit)
        for i = 1, buffCount do
            local index = buffs[i]
            if index then
                buffSubjects[index]:OnNext(unit, GetAuraData(unit, index, "HELPFUL"))
            else
                buffSubjects[index]:OnNext(unit, nil)
            end
        end
    end
else
    -- 同一个职业会互相顶的Buff
    local classBuffList         = {
        PALADIN                 = {
            -- 强效王者祝福
            [25898]             = true,
            -- 王者祝福
            [20217]             = true,
            -- 强效庇护祝福
            [27169]             = true,
            -- 庇护祝福
            [27168]             = true,
            -- 强效力量祝福
            [27141]             = true,
            -- 力量祝福
            [27140]             = true,
            -- 强效智慧祝福
            [27143]             = true,
            -- 智慧祝福
            [27142]             = true,
            -- 强效光明祝福
            [27145]             = true,
            -- 光明祝福
            [27144]             = true,
            -- 强效拯救祝福
            [25895]             = true,
            -- 拯救祝福
            [1038]              = true
        },

        MAGE                    = {
            -- 奥术智慧
            [27126]             = true,
            -- 奥术光辉
            [27127]             = true
        },

        DRUID                   = {
            -- 野性赐福
            [26991]             = true,
            -- 野性印记
            [26990]             = true
        },

        PRIEST                  = {
            -- 坚韧祷言
            [25392]             = true,
            -- 真言术：韧
            [25389]             = true,
            -- 精神祷言
            [32999]             = true,
            -- 神圣之灵
            [25312]             = true,
            -- 暗影防护祷言
            [39374]             = true,
            -- 防护暗影
            [25433]             = true
        },

        SHAMAN                  = {
            -- 大地之盾
            [32594]             = true
        }
    }

    local shouldShowClassBuff   = function(spellId)
        local buffs = classBuffList[PlayerClass]
        return buffs and buffs[spellId]
    end

    local shouldDisplayBuff     = function(unitCaster, spellId, canApplyAura)
        local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")

        local isClassBuff = shouldShowClassBuff(spellId)
        if ( hasCustom ) then
            return showForMySpec or (alwaysShowMine and (unitCaster == "player" or isClassBuff or unitCaster == "pet" or unitCaster == "vehicle")), isClassBuff
        else
            return (unitCaster == "player" or isClassBuff or unitCaster == "pet" or unitCaster == "vehicle") and canApplyAura and not SpellIsSelfBuff(spellId), isClassBuff
        end
    end

    local buffs                 = {}
    local classBuffs            = {}

    function CheckBuffStart()
        wipe(buffs)
        wipe(classBuffs)
    end

    function CheckBuff(unit, index, filter, name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
        if not _AuraBlackList[spellID] and not (_ClassBuffList[name] or _ClassBuffList[spellID]) and not EnlargeBuffList[spellID] then
            local displayBuff, isClassBuff = shouldDisplayBuff(source, spellId, canApplyAura)
            if displayBuff and not isBossDebuff then
                -- 区分职业buff和非职业buff
                if isClassBuff then
                    tinsert(classBuffs, index)
                elseif not isClassBuff then
                    tinsert(buffs, index)
                end
            end
        end
    end

    function SendBuffData(unit)
        local buffSize = #buffs
        if buffSize < buffCount then
            for i = 1, buffCount - buffSize do
                local index = classBuffs[i]
                if index then
                    tinsert(buffs, i, index)
                end
            end
        end

        for i = 1, buffCount do
            local index = buffs[i]
            if index then
                buffSubjects[index]:OnNext(unit, GetAuraData(unit, index, "HELPFUL"))
            else
                buffSubjects[index]:OnNext(unit, nil)
            end
        end
    end
end