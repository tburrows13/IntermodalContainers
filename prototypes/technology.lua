local IC = require "prototypes.shared"

-- research
for tier = 1, IC.TIERS do
	IC.create_crating_technology(tier)
end

table.insert(data.raw.technology[IC.TECH_PREFIX.."1"].effects, {
  type = "unlock-recipe",
  recipe = IC.MOD_PREFIX.."container",
})