# NPC Powers Framework (OpenMW)

A framework for giving NPCs Power-type spells.

In vanilla, NPCs can't cast Powers at all, but this framework fakes it with free spells that get removed after being cast once.

What this framework does:

- Creates copies of all available Powers as spells with no cost and a 100% success chance
- Gives modders an interface for adding Fake Powers to NPCs
- Removes a Fake Power spell once it has been used (and sends an event)
- Returns the Fake Power after 24 in-game hours (and sends an event)

What this framework doesn't do:

- Give Fake Powers to Creatures - there is no reliable way of tracking their spellcasts
- Give Fake Powers to spell merchants - to prevent players from obtaining Fake Powers

## For Modders

All Fake Powers can be identified by `fakepower_` prefix. For example:

- Real Power -> `ancestor guardian`
- Fake Power -> `fakepower_ancestor guardian`

### Interface

**Context: NPC**

```lua
---@param powerId string    Real Power id
---@return boolean          Was it successful
I.NPCPowers.addPower(powerId)

---@param powerId string    Real Power id
---@param delay number      Delay before giving the NPC Fake Power
---@return boolean          Was it successful
I.NPCPowers.addPowerDelayed(powerId, delay)

---@param powerId string    Real Power id
---@return boolean          Was it successful
I.NPCPowers.removePower(powerId)

---@return table<string, string>    Lookup table of all current Fake Powers of an NPC and their statuses (ready, cooldown)
I.NPCPowers.getCurrentPowers()
```

### Events

**Context: NPC**

#### Received

```lua
--- Equivalent to I.NPCPowers.addPower()
---@param powerId string    Real Power id
NPCPowers_addPower
```

#### Sent

```lua
--- Triggered when an NPC uses their Fake Power
---@return string    Fake Power id
NPCPowers_powerUsed

--- Triggered when an NPC's Fake Power comes off cooldown
---@return string    Fake Power id
NPCPowers_powerCooldownPassed
```

## Compatibility

Compatible with any mod that adds, changes, or removes Powers.

## Requirements

OpenMW 0.51 or newer.

## Credits

**Sosnoviy Bor** - Author
