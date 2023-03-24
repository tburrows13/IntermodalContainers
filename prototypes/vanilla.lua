local IC = require "prototypes.shared"

-- generate vanilla crates and add them to their technology
for i=1,IC.TIERS do
	for _,item in pairs(IC.VANILLA_ITEM_TIERS[i]) do
		IC.generate_crates(item, IC.VANILLA_ICON_SIZE)
		IC.add_crates_to_tech(item, IC.TECH_PREFIX..i)
		--deadlock_crating.add_crate_autotech(item)
	end
end

