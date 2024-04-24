local function length(table)
  local size = 0
  if table == nil then return size end
  for _ in pairs(table) do size = size + 1 end
  return size
end

local function is_value_in_table(t, value)
  if not t or not value then return false end
  for k,v in pairs(t) do
    if value == v then return true end
  end
  return false
end

local function list_to_map(list)
  local map = {}
  for k, value in pairs(list) do
    map[value] = true
  end
  return map
end

local function map_to_list(map)
  local list = {}
  for key, _ in pairs(map) do
    table.insert(list, key)
  end
  return list
end

local function list_to_array(list)
  local array = {}
  for _, v in pairs(item) do
      array[#array+1] = v
  end
  return array
end

-- shift icIconSpecification on by (X, Y)
-- @ icon: IconSpecification
-- @ x: Number
-- @ y: Number
local function shift_icon(icon, x, y)
  icon.shift = icon.shift or {0, 0}
  icon.shift = {icon.shift[1] + x, icon.shift[2] + y}
end

-- scale IconSpecification by value
-- @ icon: IconSpecification
-- @ scale: Number
local function scale_icon(icon, scale)
  icon.scale = (icon.scale or 1) * scale
end

-- returns whether a subgroup exists or not: Bool
-- @ subgroup: String
local function subgroup_exists(subgroup)
  for _, sg in pairs(data.raw["item-subgroup"]) do
    if sg.name == subgroup then return true end
  end
  return false
end

-- @ tech_name: String
-- @ ancestor: String
local function is_descendant_of(tech_name, ancestor)
  --if tech_name == ancestor then return true end
  local technology = data.raw.technology[tech_name]
  if not technology then return false end
  if technology.prerequisites == nil then
    return false
  end
  for ___, name in pairs(technology.prerequisites) do
    if name == ancestor then
      return true
    end
    if is_descendant_of(name, ancestor) then
      return true
    end
  end
  return false
end

-- get ItemPrototype from item name
-- @ item_name: String
local function get_item_prototype(item_name)
  -- list of base item prototypes to pick from
  local ITEM_TYPES = {
    "item",
    "ammo",
    "capsule",
    "module",
    "tool",
    "repair-tool",
  }
  for _, item_type in pairs(ITEM_TYPES) do
    if data.raw[item_type][item_name] then 
      return data.raw[item_type][item_name]
    end
  end
  return nil
end

-- return item icon(s): IconSpecification(s)
-- @ item: ItemPrototype
local function get_item_icon(item)
  -- Icons has priority over icon, check for icons definition first
  local icons = {}
  if item.icons then
    for _, icon in pairs(item.icons) do
      local temp_icon = table.deepcopy(icon)
      if not temp_icon.icon_size then temp_icon.icon_size = item.icon_size end
      temp_icon.scale = temp_icon.scale or (64 / temp_icon.icon_size)
      table.insert(icons, temp_icon)
    end
  -- If no icons field, look for icon definition
  elseif item.icon then
    table.insert(icons, {
      icon = item.icon,
      scale = 64 / (item.icon_size or 64), -- Base layer is 64 pixels, need to ensure scaling of the crated item is correct for its size
      icon_size = item.icon_size or 64,
      icon_mipmaps = item.icon_mipmaps,
    })
  else
    return nil
  end
  return icons
end

-- Checks if the recipe is enabled
-- @ recipe_name: String
local function recipe_is_enabled(recipe_name)
  local recipe = data.raw.recipe[recipe_name]
  if not recipe then return nil end
  if recipe.enabled ~= nil then return recipe.enabled end
  -- if nothing is set then recipe is enabled by default
  return true
end

-- return recipe's name given the item's name
-- default: "ic-container"
-- @ item_name: String
local function get_recipe_from_item(item_name)
  local recipes = {}
  for ___, recipe in pairs(data.raw.recipe) do
    -- recipe
    if recipe.results then
      for ___, result in pairs(recipe.results) do
        if result.name and result.name == item_name then recipes[recipe.name] = true end
      end
    end
  end
  return map_to_list(recipes)
end

-- return the name of the technology that unlocks the given recipe
-- default: nil, if not found
-- @ recipe_name: String
local function get_technology_from_recipe(recipe_name)
  local technologies = {}
  for ___, tech in pairs(data.raw.technology) do
    -- effects
    if tech.effects then
      for ___, effect in pairs(tech.effects) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe_name then technologies[tech.name] = true end
      end
    end
  end
  return map_to_list(technologies)
end

-- return the name of the technology that unlocks the given recipe
-- default: nil, if not found
-- @ recipe_name: String
local function get_technology_from_item(item_name)
  local base_item = get_item_prototype(item_name)
  if not base_item then
    log("ERROR: IC asked to crate an item that doesn't exist ("..item_name..")")
    return nil
  end

  -- get all the unique recipes that have the item as result
  local recipe_names = get_recipe_from_item(item_name)
  if #recipe_names == 0 then return nil end

  -- if any recipe is availabe, exit
  for ___, recipe in pairs(recipe_names) do
    if recipe_is_enabled(recipe) then return nil end -- shortcut
  end

  -- get all the unique technologies associated to the recipes
  local technology_names = {}
  for ___, recipe_name in pairs(recipe_names) do
    local tech_names = get_technology_from_recipe(recipe_name)
    for ___, tech_name in pairs(tech_names) do
      technology_names[tech_name] = true
    end
  end
  technology_names = map_to_list(technology_names)
  if #technology_names <= 1 then return technology_names[1] end -- shortcut

  -- try to compute dependencies
  local origin = {}
  for ___, tech in pairs(technology_names) do
    local descendant = false
    for ___, test in pairs(technology_names) do
      if tech ~= test then
      descendant = descendant or is_descendant_of(tech, test) end
    end
    if not descendant then table.insert(origin, tech) end
  end
  if #origin == 1 then return origin[1] end

  log("WARNING IC: could not decide correct technology for: "..item_name.." between:")
  log(serpent.block(origin))
  return nil
end

-- does a table of IngredientPrototypes or ProductPrototypes contain reference to an item?
local function product_prototype_uses_item(proto, item)
  for _,p in pairs(proto) do
    if p.name and p.name == item then return true
    elseif p[1] == item then return true end
  end
  return false
end

-- does a recipe reference an item in its ingredients?
local function uses_item_as_ingredient(recipe, item)
  if recipe.ingredients and product_prototype_uses_item(recipe.ingredients, item) then return true end
  return false
end

-- does a recipe reference an item in its results?
local function uses_item_as_result(recipe, item)
  if recipe.results and product_prototype_uses_item(recipe.results, item) then return true end
  return false
end

-- brighter version of tier colour for working vis glow & lights
local function brighter_colour(c)
  local w = 255
  if c.r <= 1 and c.g <= 1 and c.b <= 1 then
    c.r = c.r * 255
    c.g = c.g * 255
    c.b = c.b * 255
    if not c.a then c.a = 255
    elseif c.a <=1 then c.a = c.a * 255 end
  end
  return { r = math.floor((c.r + w)/2), g = math.floor((c.g + w)/2), b = math.floor((c.b + w)/2), a = c.a }
end

-- for calculating scales of energy, health etc.
local function get_scale(this_tier, tiers, lowest, highest)
  return lowest + ((highest - lowest) * ((this_tier - 1) / (tiers - 1)))
end

-- energy use
local function get_energy_table(this_tier, tiers, lowest, highest, passive_multiplier)
  local total = get_scale(this_tier, tiers, lowest, highest)
  local passive_energy_usage = total * passive_multiplier
  local active_energy_usage = total * (1 - passive_multiplier)
  return {
    passive = passive_energy_usage .. "KW", -- passive energy drain as a string
    active = active_energy_usage .. "KW", -- active energy usage as a string
  }
end

-- if a technology has one or more prerequistes
-- for each prerequisites check if that technology will create a cycle if require "tech"
-- and do recusively this check for his prerequistes, until reach technologies that haven't prerequisites
local function isaCircularDependency(tech, next_tech, already_checked)
  -- if has dependecy to be checked
  if data.raw.technology[next_tech] then
    local next_techs = data.raw.technology[next_tech].prerequisites
    if next_techs and next(next_techs) ~= nil then
      if already_checked == nil then
        -- inizialize memoization table
        already_checked = {}
        for name, technology in pairs(data.raw.technology) do
          already_checked[name] = false
        end
      elseif already_checked[next_tech] == true then -- skip already done recurrence
        return false
      end

      already_checked[next_tech] = true
      for _, prerequisite in pairs(next_techs) do
        -- check each prerequisite
        if data.raw.technology[prerequisite] then
          local prerequisites = data.raw.technology[prerequisite].prerequisites
          if prerequisites and next(data.raw.technology[prerequisite].prerequisites) ~= nil then
            for _, child_prerequisite in pairs(data.raw.technology[prerequisite].prerequisites) do
              if child_prerequisite == tech then
                return true
              end
            end
          end

          -- if not found check his prerequisite paths
          if isaCircularDependency(tech, prerequisite, already_checked) then
            return true
          end
        else
          log("The technology "..next_tech..", have a prerequisite called "..prerequisite..", that doesn't exist!")
          return false
        end
      end
    end
  end
  return false
end

local function scale_pos(pos, scale)
  return {pos[1] * scale, pos[2] * scale}
end

local function scale_box(box, scale)
  return {scale_pos(box[1], scale), scale_pos(box[2], scale)}
end

--------------------------

return {
  get_item_prototype = get_item_prototype,
  get_item_icon = get_item_icon,
  get_recipe_from_item = get_recipe_from_item,
  get_technology_from_recipe = get_technology_from_recipe,
  get_technology_from_item = get_technology_from_item,
  shift_icon = shift_icon,
  scale_icon = scale_icon,
  subgroup_exists = subgroup_exists,
  is_descendant_of = is_descendant_of,
  recipe_is_enabled = recipe_is_enabled,
  product_prototype_uses_item = product_prototype_uses_item,
  uses_item_as_ingredient = uses_item_as_ingredient,
  uses_item_as_result = uses_item_as_result,
  brighter_colour = brighter_colour,
  is_value_in_table = is_value_in_table,
  get_scale = get_scale,
  get_energy_table = get_energy_table,
  isaCircularDependency = isaCircularDependency,
  scale_pos = scale_pos,
  scale_box = scale_box,
}