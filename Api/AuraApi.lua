Scorpio "AshToAsh.BlizzardSkin.Api.Aura" ""

UI.Property             {
    name                = "AuraEngine",
    type                = String,
    require             = UnitFrame,
    set                 = Toolset.fakefunc
}

__Static__() __AutoCache__()
function AshBlzSkinApi.AuraEngine()
    return Wow.UnitAura():Map(ParseAura)
end

function ParseAura(unit)
    ParseAuraStart()

    local index = 1
    while true do
        local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll = UnitBuff(unit, index)
        if not name then
            break
        end

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
local dispellDebuffFlag = false

function ParseAuraStart()
    bossAuraFlag = false
    classBuffFlag = false
    enlargeDebuffFlag = false
    enlargeBuffFlag = false
    dispellDebuffFlag = false
end

function ParseAuraEnd(unit)
    SendBossAuraData(unit)
    SendClassBuffData(unit)
    SendEnlargeDebuffData(unit)
    SendEnlargeBuffData(unit)
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
-- Dispell debuff
-------------------------------------------------

function CheckDispellDebuff(unit, name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)

end

-- local i = 1
-- while true do
--     if _G["AshToAshUnit1Unit"..i] then
--         print("---AshToAshUnit1Unit"..i.."---")
--         local unitframe = Scorpio.UI.GetProxyUI(_G["AshToAshUnit1Unit"..i])
--         print(unitframe:GetName(), unitframe:GetSize())
--         local healthbar = unitframe:GetPropertyChild("PredictionHealthBar")
--         print(healthbar:GetChildPropertyName(), healthbar:GetSize(), healthbar:GetStatusBarTexture():GetSize())
        
--         local iconTexture = healthbar:GetPropertyChild("IconTexture")
--         if iconTexture then
--             print(iconTexture:GetChildPropertyName(), iconTexture:Size())
--         end
        
--         i = i + 1
--     else
--         break
--     end
-- end