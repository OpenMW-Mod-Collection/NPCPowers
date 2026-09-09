---@omw-context local
local self = require("openmw.self")
local types = require("openmw.types")
local I = require("openmw.interfaces")
local core = require("openmw.core")
local time = require("openmw_aux.time")

local C = require("scripts.NPCPowers.utils.consts")

-- anticheese
local selfRecord = types.NPC.records[self.recordId]
if not selfRecord or selfRecord.servicesOffered.Spells then
    return
end

local selfSpells = types.Actor.spells(self)
local stopKeys = {
    ["self stop"] = true,
    ["touch stop"] = true,
    ["target stop"] = true,
}
local powerStatus = {
    ready = "ready",
    cooldown = "cooldown",
}
local dead = types.Actor.isDead(self)
local selfFakePowers = {}
local powerCooldown = time.day

---@param powerId string
---@return boolean
local function isValidPowerId(powerId)
    local spellRecords = core.magic.spells.records
    if spellRecords[powerId] and spellRecords[powerId].type == core.magic.SPELL_TYPE.Power then
        return true
    else
        print(("Warning! '%s' is not a valid Power id!"):format(powerId))
        return false
    end
end

---@param powerId string
---@return boolean
local function addPower(powerId)
    if dead or not isValidPowerId(powerId) then
        return false
    end

    local fakePowerId = C.fakePowerPrefix .. powerId
    selfSpells:add(fakePowerId)
    selfFakePowers[fakePowerId] = powerStatus.ready
    return true
end

local powerCooldownPassed = time.registerTimerCallback(
    C.namespace .. "_powerCooldownPassed",
    function(fakePowerId)
        if selfFakePowers[fakePowerId] == powerStatus.cooldown then
            if addPower(fakePowerId:gsub(C.fakePowerPrefix, "")) then
                self:sendEvent(C.namespace .. "_powerCooldownPassed", fakePowerId)
            end
        end
    end
)

---@param powerId string
---@param delay number
---@return boolean
local function addPowerDelayed(powerId, delay)
    if dead or not isValidPowerId(powerId) then
        return false
    end

    local fakePowerId = C.fakePowerPrefix .. powerId
    selfFakePowers[fakePowerId] = powerStatus.cooldown
    time.newGameTimer(delay, powerCooldownPassed, fakePowerId)
    return true
end

---@param powerId string
---@return boolean
local function removePower(powerId)
    local fakePowerId = C.fakePowerPrefix .. powerId
    if not isValidPowerId(powerId) or not selfFakePowers[fakePowerId] then
        return false
    end

    selfSpells:remove(fakePowerId)
    selfFakePowers[fakePowerId] = nil
    return true
end

I.AnimationController.addTextKeyHandler('spellcast', function(groupname, key)
    if not stopKeys[key] then return end

    local currSpell = types.Actor.getSelectedSpell(self)
    if not currSpell or not selfFakePowers[currSpell.id] then return end

    selfSpells:remove(currSpell)
    selfFakePowers[currSpell.id] = powerStatus.cooldown
    time.newGameTimer(powerCooldown, powerCooldownPassed, currSpell.id)
    self:sendEvent(C.namespace .. "_powerUsed", currSpell.id)
end)

local function onSave()
    return {
        selfFakePowers = selfFakePowers
    }
end

local function onLoad(data)
    if not data then return end
    selfFakePowers = data.selfFakePowers or selfFakePowers
end

return {
    engineHandlers = {
        onSave = onSave,
        onLoad = onLoad,
    },
    eventHandlers = {
        Died = function()
            dead = true
            selfFakePowers = {}
        end,
    },
    interfaceName = C.namespace,
    interface = {
        addPower = addPower,
        addPowerDelayed = addPowerDelayed,
        removePower = removePower,
        getCurrentPowers = function()
            return selfFakePowers
        end,
    },
}
