------------------------------------------------------------------------------------------------------------------------------------------------------

-- INTERMODAL CONTAINERS API

------------------------------------------------------------------------------------------------------------------------------------------------------

local IC = require "prototypes.shared"
intermodal_containers = {}

------------------------------------------------------------------------------------------------------------------------------------------------------

--[[

	Items are automatically containerized if they meet the conditions in container-gen.lua.
	To force an item to be containerized, set ic_create_container = true in its prototype.
	To prevent an item from being containerized, set ic_create_container = false in its prototype.

]]

-- intermodal_containers.destroy_container(item_name)
-- Destroys the container of an item, all recipes which use or produce it, and removes all references to its recipe unlocks from all technologies
-- Better to use ic_create_container = false on the item's prototype to prevent it being created in the first place.
-- item_name (string) - name of the item you no longer want to be crateable
-- Example: intermodal_containers.destroy_container("copper-cable")
function intermodal_containers.destroy_container(item_name)
	if not item_name then error("IC: destroy_crate() given nil item name") end
	IC.destroy_crate(item_name)
end

-- intermodal_containers.add_tier()
-- This function will create a new tier of machine and a new technology that unlocks it.
-- If you specify a tier that already exists, it will be overwritten, so you will also have to recreate any tech unlocks that you wanted to keep.
-- parameters (table) - Takes just one argument, a table with the following keys defined (in any order because it's a table):
-- .tier (integer/string) - mandatory - the tier suffix. This is usually an integer (1-3 for the vanilla tiers) but you can specify a string if you insist.
-- .ingredients (table) - mandatory - the ingredients for the crating machine (see https://wiki.factorio.com/Prototype/Recipe#ingredients).
-- .colour (table) - optional - the tier colour. Must be a colour table in the format {r=1,g=1,b=1} (a=optional). If not specified or nil, will use default tier colours if tier is 1-3, otherwise pink.
-- .upgrade (string) - optional - the entity this machine will be automatically upgraded to by the upgrade planner. Defaults to tier+1 for numbered tiers, nil for non-numbered, if not specified/nil. 
-- .speed (float) - mandatory if tier is not a number, otherwise optional - the speed of the crating machine. Speed 1 handles a compressed vanilla yellow belt, 2 a red belt, etc. Defaults to same value as tier as long as tier is a number.
-- .pollution (float) - optional - how much pollution the machine produces. Defaults to (5-tier) if tier is a number, 1 if tier is a string.
-- .energy (string) - mandatory if tier is not a number, otherwise optional - energy usage of the machine, e.g. "1MW", "750kW" etc. Defaults to vanilla tier scheme if not specified
-- .drain (string) - mandatory if tier is not a number, otherwise optional - constant energy drain of the machine, e.g. "10kW" etc. Defaults to vanilla tier scheme if not specified
-- .prerequisites (table) - optional - a list of technology prerequisites (see https://wiki.factorio.com/Prototype/Technology#prerequisites). Can be nil.
-- .unit (table) - mandatory if tier is not 1-3, otherwise optional - the unit cost for the technology (see https://wiki.factorio.com/Prototype/Technology#unit). Defaults to native tier scheme if not specified and tier is 1-3. Cannot be nil.
-- .health (integer) - mandatory if tier is not a number, otherwise optional - the max health of the machine. Defaults to vanilla tier scheme if not specified for numbered tiers. 
-- The resulting machine item, recipe and entity will be named deadlock-crating-machine-N where N = tier. The technology is named deadlock-crating-N.
function intermodal_containers.add_tier(parameters)
	if not parameters.tier then error("IC: create_tier(): tier not specified") end
	if not parameters.ingredients then error("IC: create_tier(): ingredients not specified") end
	if not parameters.speed and type(parameters.tier) ~= "number" then error("IC: create_tier(): speed not specified for non-numeric tier") end
	if not parameters.energy and type(parameters.tier) ~= "number" then error("IC: create_tier(): energy not specified for non-numeric tier") end
	if not parameters.drain and type(parameters.tier) ~= "number" then error("IC: create_tier(): drain not specified for non-numeric tier") end
	if not parameters.unit and (type(parameters.tier) ~= "number" or parameters.tier < 1 or parameters.tier > IC.TIERS) then error("IC: create_tier(): unit not specified for non-numeric or non-vanilla tier") end
	if not parameters.health and type(parameters.tier) ~= "number" then error("IC: create_tier(): health not specified for non-numeric tier") end
	if type(parameters.tier) ~= "string" and type(parameters.tier) ~= "number" then error("IC: create_tier(): tier given as non-number and non-string") end
	if type(parameters.ingredients) ~= "table" then error("IC: create_tier(): ingredients given as non-table") end
	if parameters.colour and type(parameters.colour) ~= "table" then error("IC: create_tier(): colour given as non-table") end
	if parameters.upgrade and type(parameters.upgrade) ~= "string" then error("IC: create_tier(): upgrade given as non-string") end
	if parameters.pollution and type(parameters.pollution) ~= "number" then error("IC: create_tier(): pollution given as non-number") end
	if parameters.energy and type(parameters.energy) ~= "string" then error("IC: create_tier(): energy given as non-string") end
	if parameters.drain and type(parameters.drain) ~= "string" then error("IC: create_tier(): energy given as non-string") end
	if parameters.prerequisites and type(parameters.prerequisites) ~= "table" then error("IC: create_tier(): prerequisites given as non-table") end
	if parameters.unit and type(parameters.unit) ~= "table" then error("IC: create_tier(): unit given as non-table") end
	if parameters.health and type(parameters.health) ~= "number" then error("IC: create_tier(): health given as non-number") end
	IC.create_machine_item(parameters.tier, parameters.colour)
	IC.create_machine_recipe(parameters.tier, parameters.ingredients)
	IC.create_machine_entity(parameters.tier, parameters.colour, parameters.speed, parameters.pollution, parameters.energy, parameters.drain, parameters.upgrade, parameters.health)
	IC.create_crating_technology(parameters.tier, parameters.colour, parameters.prerequisites, parameters.unit)
end
