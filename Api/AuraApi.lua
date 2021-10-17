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

        index = index + 1
    end

    index = 1
    while true do
        local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll = UnitDebuff(unit, index)
        if not name then
            break
        end
        
        CheckLossOfControl(unit, name, icon, duration, expirationTime, spellId)
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

    ParseAuraEnd()
end

local bossAuraFlag = false
local lossOfControlFlag = false
local dispellDebuffFlag = false

function ParseAuraStart()
    bossAuraFlag = false
    lossOfControlFlag = false
    dispellDebuffFlag = false
end

function ParseAuraEnd()
    SendLossOfControlData()
    SendBossAuraData()
end

-------------------------------------------------
-- Loss of control
-------------------------------------------------

local lossOfControlSubject = BehaviorSubject()
local lossOfControlData = {}
function CheckLossOfControl(unit, name, icon, duration, expirationTime, spellId)
    if not lossOfControlFlag then 
        local displayText = _Core.AuraList.LossOfControlList[spellId]
        if displayText then
            lossOfControlFlag = true
            lossOfControlData.unit = unit
            lossOfControlData.lossOfControlText = displayText
            lossOfControlData.name = name
            lossOfControlData.icon = icon
            lossOfControlData.duration = duration
            lossOfControlData.expirationTime = expirationTime
        end
    end
end

function SendLossOfControlData()
    lossOfControlSubject:OnNext(lossOfControlData.unit, lossOfControlFlag and lossOfControlData or nil)
end

__Static__() __AutoCache__()
function AshBlzSkinApi.UnitLossOfControl()
    return Wow.FromUnitEvent(lossOfControlSubject):Map(function(unit, data)
        return data
    end)
end

-------------------------------------------------
-- Boss aura
-------------------------------------------------

local bossAuraSubject = BehaviorSubject()
local bossAuraData = {}
function CheckBossAura(unit, bossAura)
    if not bossAuraFlag then
        if bossAura then
            bossAuraFlag = true
            bossAuraData.unit = unit
        end
    end
end

function SendBossAuraData()
    bossAuraSubject:OnNext(bossAuraData.unit, bossAuraFlag and true or false)
end

-- 是否有Boss给的Aura
__Static__() __AutoCache__()
function AshBlzSkinApi.UnitBossAura()
    return Wow.FromUnitEvent(bossAuraSubject):Map(function(unit, bossAura)
        return bossAura
    end)
end

-------------------------------------------------
-- Dispell debuff
-------------------------------------------------

function CheckDispellDebuff(unit, name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)

end