local utils = require "prototypes.utils"
local IC = require "prototypes.shared"

local function add_unlocks(prototype)
  -- Not currently used
  local added_to_tech = false
  local recipes = utils.get_recipe_from_item(prototype.name)
  for tech_name, tech_prototype in pairs(data.raw.technology) do
    if tech_prototype.effects then
      for _, effect in pairs(tech_prototype.effects) do
        if effect.type == "unlock-recipe" and recipes[effect.recipe] then
          IC.add_crates_to_tech(prototype.name, tech_name)
          added_to_tech = true
        end
      end
    end
  end
  if not added_to_tech then
    IC.add_crates_to_tech(prototype.name, "ic-containerization-1")
  end
end

local banned_items = {
  ["ic-container"] = true,
  ["ee-super-fuel"] = true,
}

local function allowed_in_container(prototype)
  if prototype.name:sub(1, 13) == IC.ITEM_PREFIX then return false end
  if prototype.ic_create_container_override == true then return true end
  if prototype.ic_create_container_override == false then return false end
  if banned_items[prototype.name] then return false end
  if prototype.place_result then return false end
  if prototype.placed_as_equipment_result then return false end
  if prototype.place_as_tile then return false end
  if prototype.subgroup == "barrel" then return false end
  if utils.is_value_in_table(prototype.flags, "hidden") then return false end
  if utils.is_value_in_table(prototype.flags, "only-in-cursor") then return false end
  if utils.is_value_in_table(prototype.flags, "spawnable") then return false end
  return true
end

for item_name, prototype in pairs(data.raw.item) do
  if allowed_in_container(prototype) then
    IC.generate_crates(item_name)
    --add_unlocks(prototype)
  end
end

for item_name, prototype in pairs(data.raw.tool) do
  if allowed_in_container(prototype) then
    IC.generate_crates(item_name)
    --add_unlocks(prototype)
  end
end
