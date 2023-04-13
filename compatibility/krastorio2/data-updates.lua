if not mods["Krastorio2"] then return end

local IC = require "prototypes.shared"

-- IC's recipe and technology
-- remove automation from cont-1

-- Add containerization machines for tier 4&5 of Bob's belts
intermodal_containers.add_tier(
{
  localised_name = {"compatibility.kr-tier-4"},
  tier = 4,
  upgrade = IC.ENTITY_PREFIX.."5",
  ingredients =
  {
    { type = "item", name = IC.ENTITY_PREFIX.."3",  amount =  1 },
    { type = "item", name = "rare-metals",      amount = 20 },
    { type = "item", name = "processing-unit",  amount = 10 },
    { type = "item", name = "steel-gear-wheel", amount = 20 }
  },
  colour = { r=46, g=229, b=92 }, -- green #2EE55C
  speed = 4,
  prerequisites = { IC.TECH_PREFIX.."3", "kr-logistic-4" },
  unit =
  {
    count = 700,
    ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
      {"chemical-science-pack", 1},
      {"production-science-pack", 1},
      {"utility-science-pack", 1}
    },
    time = 30
  },
})
intermodal_containers.add_tier(
{
  localised_name = {"compatibility.kr-tier-5"},
  tier = 5,
  ingredients =
  {
    { type = "item", name = IC.ENTITY_PREFIX.."4",  amount =  1 },
    { type = "item", name = "low-density-structure",amount =  8 },
    { type = "item", name = "processing-unit",      amount = 15 },
    { type = "item", name = "imersium-gear-wheel",  amount = 20 }
  },
  colour = { r=180, g=89, b=255 }, -- purple #B459FF
  speed = 6,
  prerequisites = {IC.TECH_PREFIX.."4", "kr-logistic-5"},
  unit =
  {
    count = 800,
    ingredients =
    {
      {"production-science-pack", 1},
      {"utility-science-pack", 1},
      {"advanced-tech-card", 1}
    },
    time = 30
  },
})