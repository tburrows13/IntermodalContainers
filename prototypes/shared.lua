local item_sounds = require("__base__.prototypes.item_sounds")

local utils = require "prototypes.utils"

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
IC.BELT_SPEED = 15 * settings.startup["ic-belts-per-machine"].value

-- size of machine icons and crate background
IC.ITEM_ICON_SIZE = 64

IC.STACK_SIZE_MULTIPLIER = settings.startup["ic-stack-size-multiplier"].value

-- how many stacks can hold a crate
IC.MULTIPLIER = settings.startup["ic-stacks-per-container"].value

-- how many tiers of tech?
IC.TIERS = 3

-- how many crates in a stack of crates
IC.CRATE_STACK_SIZE = settings.startup["ic-container-stack-size"].value

-- probability of losing a container when unloading
IC.UNLOADING_LOSS_RATE = settings.startup["ic-container-loss-chance"].value

-- Number of modules for machines
IC.MODULE_SLOTS = settings.startup["ic-machine-modules"].value

-- machine colours
IC.TIER_COLOURS = {
  [1] = {r=210, g=180, b= 80},
  [2] = {r=210, g= 60, b= 60},
  [3] = {r= 80, g=180, b=210},
}
IC.DEFAULT_COLOUR = {r=1.0, g=0.75, b=0.75}

-- prefixes
IC.ITEM_PREFIX   = "ic-container-"
IC.LOAD_PREFIX   = "ic-load-"
IC.UNLOAD_PREFIX = "ic-unload-"
IC.ENTITY_PREFIX = "ic-containerization-machine-"
IC.TECH_PREFIX   = "ic-containerization-"

-- research prerequisites per tier
IC.TECH_PREREQUISITES = {
  [1] = {"automation", "bulk-inserter"},
  [2] = {"automation-2", IC.TECH_PREFIX.."1"},
  [3] = {"automation-3", "logistics-3", IC.TECH_PREFIX.."2"},
}

-- copy and multiply research cost per tier from these vanilla techs
IC.TECH_BASE = {
  [1] = "bulk-inserter",
  [2] = "inserter-capacity-bonus-3",
  [3] = "inserter-capacity-bonus-5",
}

IC.TECH_BASE_FALLBACK = {  -- Seperated And Infinite Inserter Capacity Research mod removes other techs
  [1] = nil,
  [2] = "bulk-inserter-capacity-bonus-2",
  [3] = "bulk-inserter-capacity-bonus-3",
}

IC.TECH_COUNT_FALLBACK = {
  [1] = 150,
  [2] = 250,
  [3] = 300,
}

IC.OVERSIZED_CONTAINERS = settings.startup["ic-container-oversized-icon"].value
IC.CONTAINER_PICTURE_SCALE = 2*(IC.OVERSIZED_CONTAINERS and 0.8 or 0.5)

IC.ICONS = {
  ["CORNER_R"]   = { icon = IC.P_G_ICONS.."container/container-corner-right.png", icon_size = 64, scale = 0.5, draw_background = true },
  ["ARROW_DOWN"] = { icon = IC.P_G_ICONS.."arrow/arrow.png",                      icon_size = 64, scale = 0.4, shift = { 4, 1 }, draw_background = true },
  ["CORNER_L"]   = { icon = IC.P_G_ICONS.."container/container-corner-left.png",  icon_size = 64, scale = 0.5, draw_background = true },
  ["ARROW_UP"]   = { icon = IC.P_G_ICONS.."arrow/arrow-up.png",                   icon_size = 64, scale = 0.4, shift = { -4, 0}, draw_background = true },
  ["CONTAINER"]  = { icon = IC.P_G_ICONS.."container/container.png",              icon_size = 64, scale = 0.5 },
  ["TOP_COVER"]  = { icon = IC.P_G_ICONS.."container/container-top.png",          icon_size = 64, scale = 0.5 },
}

-- debug logging
-- @ message: String
function IC.debug(message)
  if IC.LOGGING then log(message) end
end

-- return technology's name given the item's name
-- default: "ic-containerization-1"
-- @ item_name: String
function IC.get_technology_from_item(item_name)
  local default_tech = IC.TECH_PREFIX.."1"
  local proposed_tech = utils.get_technology_from_item(item_name)
  if proposed_tech and (not utils.is_descendant_of(default_tech, proposed_tech)) then 
    return proposed_tech
  end
  return default_tech
end

-- generate items and recipes for crated items
IC.CRATE_ORDER = 0
function IC.generate_crates(this_item)
  -- The crated item
  local base_item = utils.get_item_prototype(this_item)
  if not base_item then
    log("ERROR: IC asked to crate an item that doesn't exist ("..this_item..")")
    return
  end

  -- Adjust stack size
  if IC.STACK_SIZE_MULTIPLIER ~= 1 and base_item.stack_size >= 20 then
    base_item.stack_size = math.ceil(base_item.stack_size * IC.STACK_SIZE_MULTIPLIER)
  end

  local items_per_crate = math.ceil(base_item.stack_size * IC.MULTIPLIER)
  -- stop stack multiplier mods from breaking everything
  if items_per_crate > 65535 then
    log("ABORT: IC encountered a recipe with insane stack size ("..this_item..")")
    return
  end
  local weight = data.raw["utility-constants"].default.default_item_weight
  if base_item.weight then
    weight = items_per_crate * base_item.weight
  end
  local icons = utils.get_item_icon(base_item)
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
  utils.scale_icon(containeritemicons[2], 0.3)
  utils.scale_icon(containeritemicons[3], 0.3)
  utils.scale_icon(containeritemicons[4], 0.3)
  utils.shift_icon(containeritemicons[2], 0, -10)
  utils.shift_icon(containeritemicons[3], 0, -4.5)
  utils.shift_icon(containeritemicons[4], 0, 1)

  -- layers is for pictures, i.e. on-belt and on-ground
  local containeritemlayers = table.deepcopy(containeritemicons)
  for _, layer in pairs(containeritemlayers) do
    layer.filename = layer.icon
    layer.icon = nil
    layer.size = layer.icon_size or 64
    layer.icon_size = nil
    layer.shift = layer.shift or {0, 0}
    layer.shift = util.by_pixel(layer.shift[1] * IC.CONTAINER_PICTURE_SCALE, layer.shift[2] * IC.CONTAINER_PICTURE_SCALE)
    layer.scale = layer.scale * IC.CONTAINER_PICTURE_SCALE
  end

  local loadrecipeicons = {
    table.deepcopy(IC.ICONS.CORNER_R),
    table.deepcopy(icons[1]),
    table.deepcopy(IC.ICONS.ARROW_DOWN),
  }
  utils.scale_icon(loadrecipeicons[2], 0.36)
  utils.shift_icon(loadrecipeicons[2], -4.5, -4.5)

  local unloadrecipeicons = {
    table.deepcopy(IC.ICONS.CORNER_L),
    table.deepcopy(icons[1]),
    table.deepcopy(IC.ICONS.ARROW_UP),
  }
  utils.scale_icon(unloadrecipeicons[2], 0.36)
  utils.shift_icon(unloadrecipeicons[2], 4.5, -4.5)

  data:extend({
    -- the item
    {
      type = "item",
      name = IC.ITEM_PREFIX .. this_item,
      localised_name = {"item-name.ic-container-item", tostring(items_per_crate), base_item.localised_name or {"item-name."..this_item}},
      stack_size = IC.CRATE_STACK_SIZE,
      weight = weight,
      order = base_item.order,
      subgroup = "ic-" .. (base_item.subgroup or this_item),
      icons = containeritemicons,
      pictures = { layers = containeritemlayers },
      flags = {},
      inventory_move_sound = item_sounds.metal_chest_inventory_move,
      pick_sound = item_sounds.metal_chest_inventory_pickup,
      drop_sound = item_sounds.metal_chest_inventory_move,
      colorblind_aid = base_item.colorblind_aid,
    },
    -- The load recipe
    {
      type = "recipe",
      name = IC.LOAD_PREFIX .. this_item,
      localised_name = {"recipe-name.ic-load-recipe", base_item.localised_name or {"item-name."..this_item}},
      order = base_item.order,
      category = "packing",
      subgroup = IC.LOAD_PREFIX .. (base_item.subgroup or this_item),
      enabled = true,
      ingredients = {
        {type="item", name="ic-container", amount=1},
        {type="item", name=this_item, amount=items_per_crate},
      },
      icons = loadrecipeicons,
      results = {{type="item", name=IC.ITEM_PREFIX .. this_item, amount=1}},
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
      localised_name = {"recipe-name.ic-unload-recipe", base_item.localised_name or {"item-name."..this_item}},
      order = base_item.order,
      category = "packing",
      subgroup = IC.UNLOAD_PREFIX .. (base_item.subgroup or this_item),
      enabled = true,
      ingredients = {
        {type="item", name=IC.ITEM_PREFIX .. this_item, amount=1},
      },
      icons = unloadrecipeicons,
      results = {
        {type="item", name="ic-container", amount=1, probability=1 - IC.UNLOADING_LOSS_RATE},
        {type="item", name=this_item, amount=items_per_crate},
      },
      energy_required = items_per_crate / IC.BELT_SPEED,
      allow_decomposition = false,
      allow_intermediates = false,
      allow_as_intermediate = false,
      hide_from_stats = true,
      hide_from_player_crafting = true,
      unlock_results = false,
    }
  })
  -- create subgroup
  if not utils.subgroup_exists(IC.LOAD_PREFIX .. (base_item.subgroup or this_item)) then
    data:extend{
      {
        type  = "item-subgroup",
        name  = IC.LOAD_PREFIX .. (base_item.subgroup or this_item),
        group = IC.LOAD_PREFIX .. "container",
        order = "a[load]-" .. (base_item.order or "unordered"),
      },
      {
        type  = "item-subgroup",
        name  = IC.UNLOAD_PREFIX .. (base_item.subgroup or this_item),
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
  target_technology = IC.migrate_api({technology = target_technology})
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
    if utils.uses_item_as_ingredient(recipe, item_name) or utils.uses_item_as_result(recipe, item_name) then
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
        if effect.type ~= "unlock-recipe" or not utils.is_value_in_table(dead_recipes, effect.recipe) then
          table.insert(temp,effect)
        else found = true end
      end
      if found then IC.debug("IC: Removed unlocks from "..tech.name) end
      tech.effects = table.deepcopy(temp)
    end
  end
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
-- localised_name (LocalisedString) - optional - the displayed name of the machine
function IC.create_machine_entity(tier, colour, speed, pollution, energy, drain, upgrade, health, localised_name)
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
    local energy_table = utils.get_energy_table(tier, IC.TIERS, 500, 1000, 0.1)
    energy = energy_table.active
  end
  if not drain then
    if type(tier) ~= "number" then error("IC: energy drain not specified for containerization machine entity with non-numeric tier suffix") end
    local energy_table = utils.get_energy_table(tier, IC.TIERS, 500, 1000, 0.1)
    drain = energy_table.passive
  end
  if not health and type(tier) ~= "number" then error("IC: health not specified for containerization machine entity with non-numeric tier suffix") end
  if not health then health = utils.get_scale(tier, IC.TIERS, 300, 400) end
  local machine = {
    name = IC.ENTITY_PREFIX .. tier,
    type = "assembling-machine",
    localised_name = localised_name,
    next_upgrade = upgrade,
    fast_replaceable_group = "crating-machine",
    icons = {
      { icon = IC.P_G_ICONS .. "mipmaps/crating-icon-base.png", icon_size = IC.ITEM_ICON_SIZE},
      { icon = IC.P_G_ICONS .. "mipmaps/crating-icon-mask.png", icon_size = IC.ITEM_ICON_SIZE, tint = colour },
    },
    minable = {
      mining_time = 0.5,
      result = IC.ENTITY_PREFIX .. tier,
    },
    crafting_speed = speed,
    module_specification = {
      module_info_icon_shift = { 0, 0.8 },
      module_slots = IC.MODULE_SLOTS
    },
    allowed_effects = { "consumption", "pollution" },
    crafting_categories = {"packing"},
    gui_title_key = "gui-title.ic-crating",
    max_health = health,
    energy_usage = energy,
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      drain = drain,
      emissions_per_minute = { pollution = pollution },
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
    collision_box = { {-1.25,-1.25}, {1.25,1.25} },
    selection_box = { {-1.5,-1.5}, {1.5,1.5} },
    tile_width = 3,
    tile_height = 3,
    graphics_set = {
      animation = {
        layers = {
          {
            filename = IC.P_G_ENTITY .. "crating-base.png",
            animation_speed = 1 / speed,
            priority = "high",
            frame_count = 60,
            line_length = 10,
            width = 192,
            height = 192,
            shift = {0, 0},
            scale = 0.5,
          },
          {
            filename = IC.P_G_ENTITY .. "crating-mask.png",
            animation_speed = 1 / speed,
            priority = "high",
            repeat_count = 60,
            width = 192,
            height = 192,
            shift = {0, 0},
            scale = 0.5,
            tint = colour
          },
          {
            draw_as_shadow = true,
            filename = IC.P_G_ENTITY .. "crating-shadow.png",
            animation_speed = 1 / speed,
            repeat_count = 60,
            width = 384,
            height = 192,
            shift = {1.5, 0},
            scale = 0.5,
          }
        }
      },
      working_visualisations = {
        {
          animation = {
            animation_speed = 1 / speed,
            blend_mode = "additive",
            filename = IC.P_G_ENTITY .. "crating-working.png",
            priority = "high",
            frame_count = 30,
            line_length = 10,
            width = 192,
            height = 192,
            scale = 0.5,
            tint = utils.brighter_colour(colour),
          },
          light = {
            color = utils.brighter_colour(colour),
            intensity = 0.4,
            size = 9,
            shift = {0, 0},
          },
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
    impact_category = "metal",
    se_allow_in_space = true,
  }
  if settings.startup["ic-machine-size"].value == "3×4" then
    machine.tile_width = 4
    machine.collision_box = { {-1.66,-1.25}, {1.66,1.25} }
    machine.selection_box = { {-2,-1.5}, {2,1.5} }

  elseif settings.startup["ic-machine-size"].value == "4×4" then
    local SCALE = 4/3 --1.33333

    machine.tile_width = 4
    machine.tile_height = 4
    machine.collision_box = utils.scale_box(machine.collision_box, SCALE)
    machine.selection_box = utils.scale_box(machine.selection_box, SCALE)
    machine.graphics_set.animation.layers[1].scale = 0.5 * SCALE
    machine.graphics_set.animation.layers[2].scale = 0.5 * SCALE
    machine.graphics_set.animation.layers[3].scale = 0.5 * SCALE
    machine.graphics_set.animation.layers[3].shift = utils.scale_pos(machine.graphics_set.animation.layers[3].shift, SCALE)
    machine.graphics_set.working_visualisations[1].animation.scale = 0.5 * SCALE
    machine.graphics_set.working_visualisations[1].light.size = machine.graphics_set.working_visualisations[1].light.size * SCALE
    --machine.icon_draw_specification = {scale = 1.2}
  end
  data:extend({machine})
end

-- create crating machine items
-- tier (integer) - mandatory - numbered suffix appended to the name
-- colour (table) - optional - Factorio colour table - defaults to IC-defined defaults if not specified, or pink if tier is outside of range
-- localised_name (LocalisedString) - optional - the displayed name of the item
function IC.create_machine_item(tier, colour, localised_name)
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
      localised_name = localised_name,
      subgroup = "production-machine",
      stack_size = 50,
      icons = {
        { icon = IC.P_G_ICONS  .. "mipmaps/crating-icon-base.png", icon_size = IC.ITEM_ICON_SIZE },
        { icon = IC.P_G_ICONS  .. "mipmaps/crating-icon-mask.png", icon_size = IC.ITEM_ICON_SIZE, tint = colour },
      },
      icon_size = IC.ITEM_ICON_SIZE,
      order = "d-a[".. IC.ENTITY_PREFIX .."1]-" .. order,
      place_result = IC.ENTITY_PREFIX .. tier,
      flags = {},
      inventory_move_sound = item_sounds.mechanical_inventory_move,
      pick_sound = item_sounds.mechanical_inventory_pickup,
      drop_sound = item_sounds.mechanical_inventory_move,  
    }
  }
end

-- create crating machine recipes
-- tier (integer) - mandatory - numbered suffix appended to the name
-- ingredients (table) - mandatory - table of IngredientPrototypes
-- localised_name (LocalisedString) - optional - the displayed name of the recipe
function IC.create_machine_recipe(tier, ingredients, localised_name)
  if not tier then error("IC: tier not specified for crating machine recipe") end
  if not ingredients then error("IC: ingredients not specified for crating machine recipe") end
  data:extend({
    {
      type = "recipe",
      name = IC.ENTITY_PREFIX .. tier,
      localised_name = localised_name,
      enabled = false,
      ingredients = ingredients,
      results = {{type="item", name=IC.ENTITY_PREFIX .. tier, amount=1}},
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
    local base_tech = data.raw.technology[IC.TECH_BASE[tier]]
    if not base_tech or not base_tech.unit.count then
      -- In case mods have removed the base tech, or turned it into infinite (replaced count with count_formula)
      base_tech = data.raw.technology[IC.TECH_BASE_FALLBACK[tier]]
    end
    unit = table.deepcopy(base_tech.unit)
    unit.count = unit.count * 2
  end
  for _, prerequisite in pairs(prerequisites) do
    prerequisite = IC.migrate_api({technology = prerequisite})
  end
  local order = type(tier) == "number" and string.format("%03d",tier) or tier
  data:extend({
    {
      type = "technology",
      name = IC.TECH_PREFIX .. tier,
      prerequisites = prerequisites,
      unit = unit,
      icons = {
        { icon = IC.P_G_ICONS  .. "square/crating-icon-base-128.png", icon_size = 128 },
        { icon = IC.P_G_ICONS  .. "square/crating-icon-mask-128.png", icon_size = 128, tint = colour },
      },
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

-- helper function to mmigrate DCM's prefixes to IC's and maintain compatibility with other mods that use DCM
-- @ params:
-- @ [technology]: String
-- @ [machine]: String
-- @ [load]: String
-- @ [unload]: String
-- @ [item]: String
function IC.migrate_api(params)
  if params.technology then return params.technology:gsub("deadlock%-crating%-", IC.TECH_PREFIX) end
  if params.machine then return params.machine:gsub("deadlock%-crating%-machine%-", IC.ENTITY_PREFIX) end
  if params.load then return params.load:gsub("deadlock%-packrecipe%-", IC.LOAD_PREFIX) end
  if params.unload then return params.unload:gsub("deadlock%-unpackrecipe%-", IC.UNLOAD_PREFIX) end
  if params.item then return params.item:gsub("deadlock%-crate%-", IC.ITEM_PREFIX) end
  log("IC: parameter not expected")
end

return IC
