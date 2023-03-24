-- globals container
local IC = {}

-- paths
IC.PATH_MOD   = "__IntermodalContainers__/"
IC.P_GRAPHICS = IC.PATH_MOD .. "graphics/"
IC.P_G_ICONS  = IC.P_GRAPHICS .. "icons/"
IC.P_G_ENTITY = IC.P_GRAPHICS .. "entities/"

-- print to log for non-errors?
IC.LOGGING = false

-- default tier 1 belt speed in items/s. we assume other belt tiers are a multiple of this. if not, you'll have to tweak the machine yourself
IC.BELT_SPEED = 15

-- size of machine icons and crate background
IC.ITEM_ICON_SIZE = 64

-- size of vanilla's item icons
IC.VANILLA_ICON_SIZE = 32

-- how many stacks can hold a crate
IC.MULTIPLIER = 20 -- Was 5

-- how many tiers of tech?
IC.TIERS = 3

-- how many crates in a stack of crates
IC.CRATE_STACK_SIZE = 1

-- which vanilla items are automatically crated, in which tier
IC.VANILLA_ITEM_TIERS = {
  [1] = { "wood", "iron-ore", "copper-ore", "stone", "coal", "iron-plate", "copper-plate", "steel-plate", "stone-brick" },
  [2] = { "copper-cable", "iron-gear-wheel", "iron-stick", "sulfur", "plastic-bar", "solid-fuel", "electronic-circuit", "advanced-circuit" },
  [3] = { "processing-unit", "battery", "uranium-ore", "uranium-235", "uranium-238", 
  -- -- additional items, for testing
  -- "empty-barrel", "engine-unit", "electric-engine-unit", "explosives", "flying-robot-frame",
  -- "rocket-control-unit", "low-density-structure", "rocket-fuel", "nuclear-fuel",
  -- "automation-science-pack", "logistic-science-pack", "military-science-pack", "chemical-science-pack", "production-science-pack", "utility-science-pack", "space-science-pack" },
}

-- machine colours
IC.TIER_COLOURS = {
  [1] = {r=210, g=180, b= 80},
  [2] = {r=210, g= 60, b= 60},
  [3] = {r= 80, g=180, b=210},
}
IC.DEFAULT_COLOUR = {r=1.0, g=0.75, b=0.75}

-- prefixes
IC.MOD_PREFIX    = "ic-"
IC.ITEM_PREFIX   = IC.MOD_PREFIX.."container-"
IC.LOAD_PREFIX   = IC.MOD_PREFIX.."load-"
IC.UNLOAD_PREFIX = IC.MOD_PREFIX.."unload-"
IC.ENTITY_PREFIX = IC.MOD_PREFIX.."containerization-machine-"
IC.TECH_PREFIX   = IC.MOD_PREFIX.."containerization-"

-- research prerequisites per tier
IC.TECH_PREREQUISITES = {
  [1] = {"automation", "electric-engine", "stack-inserter"},
  [2] = {"automation-2", IC.TECH_PREFIX.."1"},
  [3] = {"automation-3", IC.TECH_PREFIX.."2"},
}

-- copy and multiply research cost per tier from these vanilla techs
IC.TECH_BASE = {
  [1] = "stack-inserter",
  [2] = "inserter-capacity-bonus-3",
  [3] = "inserter-capacity-bonus-5",
}

-- list of base item prototypes to pick from
IC.ITEM_TYPES = {
  "item",
  "ammo",
  "capsule",
  "module",
  "tool",
  "repair-tool",
}

IC.ICONS = {
  ["LOAD_BG"]    = { icon = IC.P_G_ICONS.."container/load-background.png",        icon_mipmaps = 1, icon_size = 64, scale = 0.5 },
  ["CORNER_R"]   = { icon = IC.P_G_ICONS.."container/container-corner-right.png", icon_mipmaps = 1, icon_size = 64, scale = 0.5 },
  ["ARROW_DOWN"] = { icon = IC.P_G_ICONS.."arrow/arrow.png",                      icon_mipmaps = 1, icon_size = 64, scale = 0.4, shift = { 4, 1 } },
  ["UNLOAD_BG"]  = { icon = IC.P_G_ICONS.."container/unload-background.png",      icon_mipmaps = 1, icon_size = 64, scale = 0.5 },
  ["CORNER_L"]   = { icon = IC.P_G_ICONS.."container/container-corner-left.png",  icon_mipmaps = 1, icon_size = 64, scale = 0.5 },
  ["ARROW_UP"]   = { icon = IC.P_G_ICONS.."arrow/arrow-up.png",                   icon_mipmaps = 1, icon_size = 64, scale = 0.4, shift = { -4, 0} },
  ["CONTAINER"]  = { icon = IC.P_G_ICONS.."container/container.png",              icon_mipmaps = 1, icon_size = 64, scale = 0.5 },
  ["TOP_COVER"]  = { icon = IC.P_G_ICONS.."container/container-top.png",          icon_mipmaps = 1, icon_size = 64, scale = 0.5 },
}

-- debug logging
function IC.debug(message)
  if IC.LOGGING then log(message) end
end

-- get item prototye
local function get_item_prototype(item_name)
  for _, item_type in pairs(IC.ITEM_TYPES) do
    if data.raw[item_type][item_name] then 
      return data.raw[item_type][item_name]
    end
  end
  return nil
end

-- shift icon by X, Y
local function shift_icon(icon, x, y)
  icon.shift = icon.shift or {0, 0}
  icon.shift = {icon.shift[1] + x, icon.shift[2] + y}
end

-- scale icon by value
local function scale_icon(icon, scale)
  icon.scale = (icon.scale or 1) * scale
end

-- return item icon(s)
local function get_item_icon(item)
  -- Icons has priority over icon, check for icons definition first
  local icons = {}
  if item.icons then
    for _,icon in pairs(item.icons) do
      local temp_icon = table.deepcopy(icon)
      temp_icon.scale = temp_icon.scale or 1
      if not temp_icon.icon_size then temp_icon.icon_size = item.icon_size end
      table.insert(icons, temp_icon)
    end
  -- If no icons field, look for icon definition
  elseif item.icon then
    table.insert(icons, {
      icon = item.icon,
      scale = 64 / item.icon_size, -- Base layer is 64 pixels, need to ensure scaling of the crated item is correct for its size
      icon_size = item.icon_size,
      icon_mipmaps = item.icon_mipmaps,
    })
  else
    return nil
  end
  return icons
end

-- returns bool
local function subgroup_exists(subgroup)
  for _, sg in pairs(data.raw["item-subgroup"]) do
    if sg.name == subgroup then return true end
  end
  return false
end

-- generate items and recipes for crated items
IC.CRATE_ORDER = 0
function IC.generate_crates(this_item, icon_size)
  if icon_size then
    if (icon_size ~= 32 and icon_size ~= 64 and icon_size ~= 128) then
      log("ERROR: IC asked to use icon_size that is not 32, 64 or 128")
      return
    end
  else icon_size = IC.ITEM_ICON_SIZE end
  -- The crated item
  local base_item = get_item_prototype(this_item)
  if not base_item then
    log("ERROR: IC asked to crate an item that doesn't exist ("..this_item..")")
    return
  end
  local items_per_crate = base_item.stack_size * IC.MULTIPLIER
  -- stop stack multiplier mods from breaking everything
  if items_per_crate > 65535 then
    log("ABORT: IC encountered a recipe with insane stack size ("..this_item..")")
    return
  end
  local icons = get_item_icon(base_item)
  if not icons then 
    log("ERROR: IC asked to crate an item with no icon or icons properties ("..this_item..")")
    return
  end
  -- assemble sets of icons for recipes & crate
  local containeritemicons = {
    table.deepcopy(IC.ICONS.CONTAINER),
    table.deepcopy(icons[1]),
    table.deepcopy(icons[1]),
    table.deepcopy(icons[1]),
    table.deepcopy(IC.ICONS.TOP_COVER),
  }
  scale_icon(containeritemicons[2], 0.3)
  scale_icon(containeritemicons[3], 0.3)
  scale_icon(containeritemicons[4], 0.3)
  shift_icon(containeritemicons[2], 0, -10)
  shift_icon(containeritemicons[3], 0, -4.5)
  shift_icon(containeritemicons[4], 0, 1)
  local containeritemlayers = table.deepcopy(containeritemicons)
  for _, layer in pairs(containeritemlayers) do
    layer.filename = layer.icon
    layer.icon = nil
    layer.size = layer.icon_size
    layer.icon_size = nil
    layer.mipmap_count = layer.icon_mipmaps
    layer.icon_mipmaps = nil
    layer.shift = layer.shift or {0, 0}
    layer.shift = util.by_pixel(layer.shift[1], layer.shift[2])
  end
  local loadrecipeicons = {
    table.deepcopy(IC.ICONS.LOAD_BG),
    table.deepcopy(IC.ICONS.CORNER_R),
    table.deepcopy(icons[1]),
    table.deepcopy(IC.ICONS.ARROW_DOWN),
  }
  scale_icon(loadrecipeicons[3], 0.36)
  shift_icon(loadrecipeicons[3], -4.5, -4.5)
  local unloadrecipeicons = {
    table.deepcopy(IC.ICONS.UNLOAD_BG),
    table.deepcopy(IC.ICONS.CORNER_L),
    table.deepcopy(icons[1]),
    table.deepcopy(IC.ICONS.ARROW_UP),
  }
  scale_icon(unloadrecipeicons[3], 0.36)
  shift_icon(unloadrecipeicons[3], 4.5, -4.5)

  data:extend({
    -- the item
    {
      type = "item",
      name = IC.ITEM_PREFIX .. this_item,
      localised_name = {"item-name.ic-container-item", items_per_crate, {"item-name."..this_item}},
      stack_size = IC.CRATE_STACK_SIZE,
      order = base_item.order,
      subgroup = IC.LOAD_PREFIX .. base_item.subgroup,
      allow_decomposition = false,
      icons = containeritemicons,
      pictures = { layers = containeritemlayers },
      flags = {},
    },
    -- The load recipe
    {
      type = "recipe",
      name = IC.LOAD_PREFIX .. this_item,
      localised_name = {"recipe-name.ic-load-recipe", {"item-name."..this_item}},
      order = base_item.order, 
      category = "packing",
      subgroup = IC.LOAD_PREFIX .. base_item.subgroup,
      enabled = false,
      ingredients = {
        {IC.MOD_PREFIX.."container", 1},
        {this_item, items_per_crate},
      },
      icons = loadrecipeicons,
      result = IC.ITEM_PREFIX .. this_item,
      energy_required = items_per_crate / IC.BELT_SPEED,
      allow_decomposition = false,
      allow_intermediates = false,
      allow_as_intermediate = false,
      hide_from_stats = true,
      hide_from_player_crafting = true,
    },
    -- The unload recipe
    {
      type = "recipe",
      name = IC.UNLOAD_PREFIX .. this_item,
      localised_name = {"recipe-name.ic-unload-recipe", {"item-name."..this_item}},
      order = base_item.order,
      category = "packing",
      subgroup = IC.UNLOAD_PREFIX .. base_item.subgroup,
      enabled = false,
      ingredients = {
        {IC.ITEM_PREFIX .. this_item, 1},
      },
      icons = unloadrecipeicons,
      results = {
        {type = "item", name = IC.MOD_PREFIX.."container", amount = 1, probability = 0.99},
        {this_item, items_per_crate},
      },
      energy_required = items_per_crate / IC.BELT_SPEED,
      allow_decomposition = false,
      allow_intermediates = false,
      allow_as_intermediate = false,
      hide_from_stats = true,
      hide_from_player_crafting = true,
    }
  })
  -- create subgroup
  if not subgroup_exists(IC.LOAD_PREFIX .. base_item.subgroup) then
    data:extend{
      {
        type  = "item-subgroup",
        name  = IC.LOAD_PREFIX .. base_item.subgroup,
        group = IC.LOAD_PREFIX .. "container",
        order = "a[load]-" .. (base_item.order or "unordered"),
      },
      {
        type  = "item-subgroup",
        name  = IC.UNLOAD_PREFIX .. base_item.subgroup,
        group = IC.UNLOAD_PREFIX .. "container",
        order = "b[unload]-" .. (base_item.order or "unordered"),
      }
  }
  end
  IC.debug("IC: containers created: "..this_item)
  IC.CRATE_ORDER = IC.CRATE_ORDER + 1
end

-- add recipe unlocks to a specified technology
function IC.add_crates_to_tech(item_name, target_technology)
  if not target_technology then
    IC.debug("IC: Skipping technology insert, no tech specified ("..item_name..")")
    return
  end
  if not data.raw.recipe[IC.UNLOAD_PREFIX..item_name] then
    log("ERROR: IC asked to use non-existent unloading recipe for tech ("..target_technology..")")
    return
  end
  if not data.raw.recipe[IC.LOAD_PREFIX..item_name] then
    log("ERROR: IC asked to use non-existent loading recipe for tech ("..target_technology..")")
    return
  end
  if not data.raw.technology[target_technology] then
    log("ERROR: IC asked to use non-existent technology ("..target_technology..")")
    return
  end
  -- request by orzelek - remove previous recipe unlocks if we're re-adding something that was changed by another mod
  for i,effect in ipairs(data.raw.technology[target_technology].effects) do
    if effect.recipe and (effect.recipe == IC.LOAD_PREFIX..item_name or effect.recipe == IC.UNLOAD_PREFIX..item_name) then
      table.remove(data.raw.technology[target_technology].effects, i)
      IC.debug("IC: Removed previous recipe unlock ("..item_name..")")
      break
    end
  end
  -- crating recipe
  table.insert(data.raw.technology[target_technology].effects,
    {
      type = "unlock-recipe",
      recipe = IC.LOAD_PREFIX..item_name,
    }
  )
  -- uncrating recipe
  table.insert(data.raw.technology[target_technology].effects,
    {
      type = "unlock-recipe",
      recipe = IC.UNLOAD_PREFIX..item_name,
    }
  )
  IC.debug("IC: Modified technology: "..target_technology)
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
  if recipe.normal and recipe.normal.ingredients and product_prototype_uses_item(recipe.normal.ingredients, item) then return true end
  if recipe.expensive and recipe.expensive.ingredients and product_prototype_uses_item(recipe.expensive.ingredients, item) then return true end
  return false
end

-- does a recipe reference an item in its results?
local function uses_item_as_result(recipe, item)
  if recipe.result == item then return true end
  if recipe.normal and recipe.normal.result == item then return true end
  if recipe.expensive and recipe.expensive.result == item then return true end
  if recipe.results and product_prototype_uses_item(recipe.results, item) then return true end
  if recipe.normal and recipe.normal.results and product_prototype_uses_item(recipe.normal.results, item) then return true end
  if recipe.expensive and recipe.expensive.results and product_prototype_uses_item(recipe.expensive.results, item) then return true end
  return false
end

local function is_value_in_table(t, value)
  if not t or not value then return false end
  for k,v in pairs(t) do
    if value == v then return true end
  end
  return false
end

-- remove an item and any recipes and technologies that reference it
function IC.destroy_crate(base_item_name)
  local item_name = IC.ITEM_PREFIX .. base_item_name
  local stack_recipe_name = IC.LOAD_PREFIX .. base_item_name
  local unstack_recipe_name = IC.UNLOAD_PREFIX .. base_item_name
  -- remove the item
  if data.raw.item[item_name] then
    IC.debug("IC: Removed item "..item_name)
    data.raw.item[item_name] = nil
  end
  -- remove all recipes that use stacks as either ingredient or result
  -- we don't only target native crate/uncrate recipes because other mods may have used crates as ingredients by now
  -- keep a list of which recipes got removed, so we can search tech unlocks
  local dead_recipes = {}
  for _,recipe in pairs(data.raw.recipe) do
    if uses_item_as_ingredient(recipe, item_name) or uses_item_as_result(recipe, item_name) then
      IC.debug("IC: Removed recipe "..recipe.name)
      data.raw.recipe[recipe.name] = nil
      table.insert(dead_recipes, recipe.name)
    end
  end
  -- remove all the removed recipe tech unlocks
  for _,tech in pairs(data.raw.technology) do
    if tech.effects then
      local temp = {}
      local found = false
      for _,effect in pairs(tech.effects) do
        if effect.type ~= "unlock-recipe" or not is_value_in_table(dead_recipes, effect.recipe) then
          table.insert(temp,effect)
        else found = true end
      end
      if found then IC.debug("IC: Removed unlocks from "..tech.name) end
      tech.effects = table.deepcopy(temp)
    end
  end
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

-- create crating machine entities
-- tier (integer) - mandatory - numbered suffix appended to the name
-- colour (table) - optional - Factorio colour table - defaults to IC-defined defaults if not specified, or pink if tier is outside of range
-- speed (float) - optional - machine crafting speed, default = tier if not specified
-- pollution (float) - optional - pollution produced by machine. defaults to (5 - tier) if tier is 1-3, 1 for any other value
-- energy (string) - mandatory if tier is not a number, otherwise optional - energy usage of the machine, e.g. "1MW", "750kW" etc. Defaults to vanilla tier scheme if not specified
-- drain (string) - mandatory if tier is not a number, otherwise optional - constant energy drain of the machine, e.g. "10kW" etc. Defaults to vanilla tier scheme if not specified
-- upgrade (string) - optional - the entity this machine will be automatically upgraded to by the upgrade planner.
-- health (integer) - mandatory if tier is not a number, otherwise optional - the max health of the machine. Defaults to vanilla tier scheme if not specified for numbered tiers.
function IC.create_machine_entity(tier, colour, speed, pollution, energy, drain, upgrade, health)
  if not tier then error("IC: tier not specified for containerization machine entity") end
  if not speed then
    if type(tier) ~= "number" then error("IC: speed not specified for containerization machine entity with non-numeric tier suffix") end
    speed = tier
  end
  if not colour then
    if tier > 0 and tier <= IC.TIERS then colour = IC.TIER_COLOURS[tier]
    else colour = IC.DEFAULT_COLOUR end
  end
  if not pollution then
    if type(tier) == "number" then
      if (tier < 1 or tier > IC.TIERS) then pollution = 1
      else pollution = 5 - tier end
    else pollution = 1 end
  end
  if not energy then
    if type(tier) ~= "number" then error("IC: energy usage not specified for containerization machine entity with non-numeric tier suffix") end
    local energy_table = get_energy_table(tier, IC.TIERS, 500, 1000, 0.1)
    energy = energy_table.active
  end
  if not drain then
    if type(tier) ~= "number" then error("IC: energy drain not specified for containerization machine entity with non-numeric tier suffix") end
    local energy_table = get_energy_table(tier, IC.TIERS, 500, 1000, 0.1)
    drain = energy_table.passive
  end
  if not health and type(tier) ~= "number" then error("IC: health not specified for containerization machine entity with non-numeric tier suffix") end
  if not health then health = get_scale(tier, IC.TIERS, 300, 400) end
  local machine = {
    name = IC.ENTITY_PREFIX .. tier,
    type = "assembling-machine",
    next_upgrade = upgrade,
    fast_replaceable_group = "crating-machine",
    icons = {
      { icon = IC.P_G_ICONS .. "mipmaps/crating-icon-base.png", icon_size = IC.ITEM_ICON_SIZE, icon_mipmaps = 4 },
      { icon = IC.P_G_ICONS .. "mipmaps/crating-icon-mask.png", icon_size = IC.ITEM_ICON_SIZE, tint = colour, icon_mipmaps = 4 },
    },
    minable = {
      mining_time = 0.5,
      result = IC.ENTITY_PREFIX .. tier,
    },
    crafting_speed = speed,
    module_specification = {
      module_info_icon_shift = { 0, 0.8 },
      module_slots = 1
    },
    allowed_effects = {"consumption"},
    crafting_categories = {"packing"},
    gui_title_key = "gui-title.ic-crating",
    max_health = health,
    energy_usage = energy,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      drain = drain,
      emissions_per_minute = pollution,
    },
    dying_explosion = "medium-explosion",
    resistances = {
      {
        type = "fire",
        percent = 90
      },
    },
    corpse = "big-remnants",
    flags = {
      "placeable-neutral",
      "placeable-player",
      "player-creation"
    },
    collision_box = { {-1.3,-1.3}, {1.3,1.3} },
    selection_box = { {-1.5,-1.5}, {1.5,1.5} },
    tile_width = 3,
    tile_height = 3,
    animation = {
      layers = {
        {
          hr_version = {
            filename = IC.P_G_ENTITY .. "high/crating-base.png",
            animation_speed = 1 / speed,
            priority = "high",
            frame_count = 60,
            line_length = 10,
            height = 192,
            scale = 0.5,
            shift = {0, 0},
            width = 192
          },
          filename = IC.P_G_ENTITY .. "low/crating-base.png",
          animation_speed = 1 / speed,
          priority = "high",
          frame_count = 60,
          line_length = 10,
          height = 96,
          scale = 1,
          shift = {0, 0},
          width = 96
        },
        {
          hr_version = {
            filename = IC.P_G_ENTITY .. "high/crating-mask.png",
            animation_speed = 1 / speed,
            priority = "high",
            repeat_count = 60,
            height = 192,
            scale = 0.5,
            shift = {0, 0},
            width = 192,
            tint = colour
          },
          filename = IC.P_G_ENTITY .. "low/crating-mask.png",
          animation_speed = 1 / speed,
          priority = "high",
          repeat_count = 60,
          height = 96,
          scale = 1,
          shift = {0, 0},
          width = 96,
          tint = colour,
        },
        {
          hr_version = {
            draw_as_shadow = true,
            filename = IC.P_G_ENTITY .. "high/crating-shadow.png",
            animation_speed = 1 / speed,
            repeat_count = 60,
            height = 192,
            scale = 0.5,
            shift = {1.5, 0},
            width = 384
          },
          draw_as_shadow = true,
          filename = IC.P_G_ENTITY .. "low/crating-shadow.png",
          animation_speed = 1 / speed,
          repeat_count = 60,
          height = 96,
          scale = 1,
          shift = {1.5, 0},
          width = 192
        }
      }
    },
    working_visualisations = {
      {
        animation = {
          hr_version = {
            animation_speed = 1 / speed,
            blend_mode = "additive",
            filename = IC.P_G_ENTITY .. "high/crating-working.png",
            frame_count = 30,
            line_length = 10,
            height = 192,
            priority = "high",
            scale = 0.5,
            tint = brighter_colour(colour),
            width = 192
          },
          animation_speed = 1 / speed,
          blend_mode = "additive",
          filename = IC.P_G_ENTITY .. "low/crating-working.png",
          frame_count = 30,
          line_length = 10,
          height = 96,
          priority = "high",
          tint = brighter_colour(colour),
          width = 96
        },
        light = {
          color = brighter_colour(colour),
          intensity = 0.4,
          size = 9,
          shift = {0, 0},
        },
      },
    },
    working_sound = { filename = IC.PATH_MOD .. "sounds/deadlock-crate-machine.ogg", volume = 0.7 },
    open_sound = {
      filename = "__base__/sound/machine-open.ogg",
      volume = 0.75
    },
    close_sound = {
      filename = "__base__/sound/machine-close.ogg",
      volume = 0.75
    },
    mined_sound = {
      filename = "__base__/sound/deconstruct-bricks.ogg"
    },
    vehicle_impact_sound = {
      filename = "__base__/sound/car-metal-impact.ogg",
      volume = 0.65
    },
  }
  data:extend({machine})
end

-- create crating machine items
-- tier (integer) - mandatory - numbered suffix appended to the name
-- colour (table) - optional - Factorio colour table - defaults to IC-defined defaults if not specified, or pink if tier is outside of range
function IC.create_machine_item(tier, colour)
  if not tier then error("IC: tier not specified for crating machine item") end
  if not colour then
    if tier > 0 and tier <= IC.TIERS then colour = IC.TIER_COLOURS[tier]
    else colour = IC.DEFAULT_COLOUR end
  end
  local order = type(tier) == "number" and string.format("%03d",tier) or tier
  data:extend {
    {
      type = "item",
      name = IC.ENTITY_PREFIX .. tier,
      subgroup = "production-machine",
      stack_size = 50,
      icons = {
        { icon = IC.P_G_ICONS  .. "mipmaps/crating-icon-base.png", icon_size = IC.ITEM_ICON_SIZE, icon_mipmaps = 4 },
        { icon = IC.P_G_ICONS  .. "mipmaps/crating-icon-mask.png", icon_size = IC.ITEM_ICON_SIZE, tint = colour, icon_mipmaps = 4 },
      },
      icon_size = IC.ITEM_ICON_SIZE,
      order = "z[crating-machine]-" .. order,
      place_result = IC.ENTITY_PREFIX .. tier,
      flags = {},
    }
  }
end

-- create crating machine recipes
-- tier (integer) - mandatory - numbered suffix appended to the name
-- ingredients (table) - mandatory - table of IngredientPrototypes
function IC.create_machine_recipe(tier, ingredients)
  if not tier then error("IC: tier not specified for crating machine recipe") end
  if not ingredients then error("IC: ingredients not specified for crating machine recipe") end
  data:extend({
    {
      type = "recipe",
      name = IC.ENTITY_PREFIX .. tier,
      enabled = false,
      ingredients = ingredients,
      result = IC.ENTITY_PREFIX .. tier,
      energy_required = 3.0,
    }
  })
end

-- create crating machine technologies - adds a new tech that unlocks a machine (crates added later on crate creation)
-- tier (integer) - mandatory - numbered suffix appended to the name
-- colour (table) - optional - Factorio colour table - defaults to IC-defined defaults if not specified, or pink if tier is outside of range
-- prerequisites (table) - optional - prerequisites techs, defaults to IC native spec if tier within range, otherwise no prereqs
-- unit (table) - mandatory if outside native tech tier range otherwise optional - unit spec for tech cost (see https://wiki.factorio.com/Prototype/Technology#unit)
function IC.create_crating_technology(tier, colour, prerequisites, unit)
  if not tier then error("IC: tier not specified for crating machine technology") end
  if not colour then
    if tier >= 1 and tier <= IC.TIERS then colour = IC.TIER_COLOURS[tier]
    else colour = IC.DEFAULT_COLOUR end
  end
  if not prerequisites and tier >= 1 and tier <= IC.TIERS then prerequisites = IC.TECH_PREREQUISITES[tier] end
  if not unit then
    if tier < 1 or tier > IC.TIERS then error("IC: asked to create a technology outside of vanilla tier range, but research unit costs were not specified") end
    unit = table.deepcopy(data.raw.technology[IC.TECH_BASE[tier]].unit)
    unit.count = unit.count * 2
  end
  local order = type(tier) == "number" and string.format("%03d",tier) or tier
  data:extend({
    {
      type = "technology",
      name = IC.TECH_PREFIX .. tier,
      prerequisites = prerequisites,
      unit = unit,
      icons = {
        { icon = IC.P_G_ICONS  .. "square/crating-icon-base-128.png" },
        { icon = IC.P_G_ICONS  .. "square/crating-icon-mask-128.png", tint = colour },
      },
      icon_size = 128,
      order = order,
      effects = {
        {
          type = "unlock-recipe",
          recipe = IC.ENTITY_PREFIX .. tier
        }
      },
    }
  })
end

return IC
