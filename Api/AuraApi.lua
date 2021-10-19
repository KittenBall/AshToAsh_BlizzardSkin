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

        CheckBossAura(unit, isBossDebuff)
        CheckClassBuff(unit, index, "HELPFUL", name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)

        index = index + 1
    end

    index = 1
    while true do
        local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll = UnitDebuff(unit, index)
        if not name then
            break
        end
        
        CheckBossAura(unit, isBossDebuff)

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
local dispellDebuffFlag = false

function ParseAuraStart()
    bossAuraFlag = false
    classBuffFlag = false
    dispellDebuffFlag = false
end

function ParseAuraEnd(unit)
    SendBossAuraData(unit)
    SendClassBuffData(unit)
end

-------------------------------------------------
-- Boss aura
-------------------------------------------------

local bossAuraSubject = BehaviorSubject()
function CheckBossAura(unit, bossAura)
    if not bossAuraFlag then
        if bossAura then
            bossAuraFlag = true
        end
    end
end

function SendBossAuraData(unit)
    bossAuraSubject:OnNext(unit, bossAuraFlag and true or false)
end

-- 是否有Boss给的Aura
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitBossAura()
    return Wow.FromUnitEvent(bossAuraSubject):Map(function(unit, bossAura)
        return bossAura
    end)
end

-------------------------------------------------
-- Class buff
-------------------------------------------------

local classBuffSubject = BehaviorSubject()
local classBuffData = {}
function CheckClassBuff(unit, index, filter, name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)
    if not classBuffFlag then
        if _ClassBuffList[name] or _ClassBuffList[spellID] then
            classBuffFlag = true
            classBuffData.Index = index
            classBuffData.Name = name
            classBuffData.Icon = icon
            classBuffData.Count = count
            classBuffData.DebuffType = dispelType
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
    return Wow.FromUnitEvent(classBuffSubject):Map(function(unit, classData)
        return classData
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