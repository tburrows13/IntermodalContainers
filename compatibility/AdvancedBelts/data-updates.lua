if not mods["AdvancedBelts"] then return end
local IC = require "prototypes.shared"

-- IC's technology and upgrade planner
data.raw["assembling-machine"][IC.ENTITY_PREFIX.."3"].next_upgrade = IC.ENTITY_PREFIX.."4"

local tech_bases = {
  [4] = "extreme-logistics",
  [5] = "ultimate-logistics",
  [6] = "high-speed-logistics",
}

local tech_units = {}
for tier, tech_name in pairs(tech_bases) do
  local base_tech = data.raw.technology[tech_name]
  unit = table.deepcopy(base_tech.unit)
  unit.count = unit.count * 2
  tech_units[tier] = unit
end

-- Add containerization machines for tier 4&5 of Krastorio2 belts
intermodal_containers.add_tier(
{
  localised_name = {"entity-name.ic-containerization-machine-4-advanced-belts"},
  tier = 4,
  upgrade = IC.ENTITY_PREFIX.."5",
  ingredients =
  {
    { type = "item", name = IC.ENTITY_PREFIX.."3",  amount =  1 },
    {"electric-engine-unit", 12},
    {"advanced-circuit", 12},
    {"steel-plate", 50},
    },
  colour = {r = 7, g = 245, b = 7, a = 255},
  speed = 4,
  prerequisites = { "extreme-logistics", IC.TECH_PREFIX.."3"}, -- Advanced
  unit = tech_units[4],
})
intermodal_containers.add_tier(
{
  localised_name = {"entity-name.ic-containerization-machine-5-advanced-belts"},
  tier = 5,
  upgrade = IC.ENTITY_PREFIX.."6",
  ingredients =
  {
    { type = "item", name = IC.ENTITY_PREFIX.."4",  amount =  1 },
    {"electric-engine-unit", 15},
    {"advanced-circuit", 15},
    {"steel-plate", 60},
    },
  colour = {r = 255, g = 113, b = 62, a = 255},
  speed = 5,
  prerequisites = {"ultimate-logistics", IC.TECH_PREFIX.."4"},
  unit = tech_units[5],
})
intermodal_containers.add_tier(
{
  localised_name = {"entity-name.ic-containerization-machine-6-advanced-belts"},
  tier = 6,
  ingredients =
  {
    { type = "item", name = IC.ENTITY_PREFIX.."5",  amount =  1 },
    {"electric-engine-unit", 20},
    {"advanced-circuit", 20},
    {"steel-plate", 70},
    },
  colour = {r = 255, g = 68, b = 181, a = 231},
  speed = 6,
  prerequisites = {"high-speed-logistics", IC.TECH_PREFIX.."5"},
  unit = tech_units[6],
})
