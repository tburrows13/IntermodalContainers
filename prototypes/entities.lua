local IC = require "prototypes.shared"

for tier = 1,IC.TIERS do
	IC.create_machine_entity(tier, nil, nil, nil, nil, nil, (tier < IC.TIERS) and (IC.ENTITY_PREFIX..(tier+1)) or nil, nil)
end
