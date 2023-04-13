local IC = require "prototypes.shared"

if mods["boblogistics"] and mods["boblibrary"] then
  -- IC's recipe and technology
  bobmods.lib.recipe.replace_ingredient(IC.ENTITY_PREFIX.."1", "stack-inserter", "red-stack-inserter")
  bobmods.lib.tech.add_prerequisite(IC.TECH_PREFIX.."1", "engine")
  bobmods.lib.tech.add_prerequisite(IC.TECH_PREFIX.."3", "logistics-3")
  data.raw["assembling-machine"][IC.ENTITY_PREFIX.."3"].next_upgrade = IC.ENTITY_PREFIX.."4"

  -- Add containerization machines for tier 4&5 of Bob's belts
  intermodal_containers.add_tier(
  {
    localised_name = {"compatibility.bobs-tier-4"}, -- Turbo
    tier = 4,
    upgrade = IC.ENTITY_PREFIX.."5",
    ingredients =
    {
      { type = "item", name = IC.ENTITY_PREFIX.."3",  amount =  1 },
      { type = "item", name = "electric-engine-unit", amount = 20 },
      { type = "item", name = "advanced-circuit",     amount = 20 },
      { type = "item", name = "steel-plate",          amount = 60 }
    },
    colour = { r=180, g=89, b=255 }, -- purple #B459FF
    speed = 4,
    prerequisites = { IC.TECH_PREFIX.."3", "logistics-4" },
    unit =
    {
      count = 700,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 30
    },
  })
  intermodal_containers.add_tier(
  {
    localised_name = {"compatibility.bobs-tier-5"}, -- Ultimate
    tier = 5,
    ingredients =
    {
      { type = "item", name = IC.ENTITY_PREFIX.."4",  amount =  1 },
      { type = "item", name = "electric-engine-unit", amount = 30 },
      { type = "item", name = "advanced-circuit",     amount = 30 },
      { type = "item", name = "steel-plate",          amount = 80 }
    },
    colour = { r=46, g=229, b=92 }, -- green #2EE55C
    speed = 5,
    prerequisites = {IC.TECH_PREFIX.."4", "logistics-5"},
    unit =
    {
      count = 800,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 30
    },
  })
end