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
local dispellDebuffFlag = false

function ParseAuraStart()
    bossAuraFlag = false
    dispellDebuffFlag = false
end

function ParseAuraEnd(unit)
    SendBossAuraData(unit)
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
-- Dispell debuff
-------------------------------------------------

function CheckDispellDebuff(unit, name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll)

end