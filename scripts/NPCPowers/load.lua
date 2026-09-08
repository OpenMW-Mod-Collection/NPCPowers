---@omw-context load
local content = require("openmw.content")

local C = require("scripts.NPCPowers.utils.consts")

local fakePowers = {}

for _, spell in ipairs(content.spells.records) do
    if spell.type == content.spells.TYPE.Power then
        fakePowers[C.fakePowerPrefix .. spell.id] = {
            alwaysSucceedFlag = true,
            cost = 0,
            effects = spell.effects,
            isAutocalc = false,
            name = spell.name,
            starterSpellFlag = false,
            type = content.spells.TYPE.Spell
        }
    end
end

for id, fakePower in pairs(fakePowers) do
    content.spells.records[id] = fakePower
end
