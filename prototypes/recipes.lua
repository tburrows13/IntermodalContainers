local IC = require "prototypes.shared"

-- the machines
IC.create_machine_recipe(1, {
	{"engine-unit", 4},
	{"stack-inserter", 1},
	{"steel-plate", 20},
})

IC.create_machine_recipe(2, {
	{IC.ENTITY_PREFIX.."1", 1},
	{"electric-engine-unit", 2},
	{"stack-inserter", 2},
	{"steel-plate", 30},
})

IC.create_machine_recipe(3, {
	{IC.ENTITY_PREFIX.."2", 1},
  {"electric-engine-unit", 8},
  {"advanced-circuit", 8},
	{"steel-plate", 40},
})

-- crafting tab groups
data:extend({
  -- Pack Group
  {
    name = IC.MOD_PREFIX .. "containers",
    order = "y-0",
    type = "item-group",
    icon_size = 128,
    icons = {
      {
        icon = IC.P_G_ICONS .. "square/crating-icon-base-128.png"
      },
      {
        icon = IC.P_G_ICONS .. "square/crating-icon-mask-128.png",
        tint = IC.TIER_COLOURS[1]
      },
    },
  },
  {
    name = IC.LOAD_PREFIX .. "container",
    order = "y-1",
    type = "item-group",
    icon_size = 128,
    icons = {
    {
      icon = IC.P_G_ICONS .. "square/crating-icon-base-128.png"
    },
    {
      icon = IC.P_G_ICONS .. "square/crating-icon-mask-128.png",
      tint = IC.TIER_COLOURS[1]
    },
    {
      icon = IC.P_G_ICONS .. "arrow/arrow.png",
      icon_size = 64,
      icon_mipmaps = 1,
      scale = 1.6,
      shift = {0, 0}
    }
    },
  },
  -- Unpack Group
  {
    name = IC.UNLOAD_PREFIX .. "container",
    order = "y-2",
    type = "item-group",
    icon_size = 128,
    icons = {
    {
      icon = IC.P_G_ICONS .. "square/crating-icon-base-128.png"
    },
    {
      icon = IC.P_G_ICONS .. "square/crating-icon-mask-128.png",
      tint = IC.TIER_COLOURS[1]
    },
    {
      icon = IC.P_G_ICONS .. "arrow/arrow-up.png",
      icon_size = 64,
      icon_mipmaps = 1,
      scale = 1.6,
      shift = {0, 0}
    }
    },
  },
})

-- Create item subgroups
for name, subgroup in pairs(data.raw["item-subgroup"]) do
  if subgroup.group ~= IC.MOD_PREFIX .. "containers" and subgroup.group ~= IC.LOAD_PREFIX .. "container" and subgroup.group ~= IC.UNLOAD_PREFIX .. "container" then
    data:extend{
      {
        type  = "item-subgroup",
        name  = IC.MOD_PREFIX .. name,
        group = IC.MOD_PREFIX .. "containers",
        order = "a[container]-" .. (subgroup.order or "unordered"),
      },
      {
        type  = "item-subgroup",
        name  = IC.LOAD_PREFIX .. name,
        group = IC.LOAD_PREFIX .. "container",
        order = "a[load]-" .. (subgroup.order or "unordered"),
      },
      {
        type  = "item-subgroup",
        name  = IC.UNLOAD_PREFIX .. name,
        group = IC.UNLOAD_PREFIX .. "container",
        order = "b[unload]-" .. (subgroup.order or "unordered"),
      }
    }
  end
end

-- crafting category for packing/unpacking
data:extend {
  {
    type = "recipe-category",
    name = "packing",
  },
}

-- container recipe
data:extend { 
  {
    type = "recipe",
    name = IC.MOD_PREFIX.."container",
    enabled = false,
    ingredients = { {"steel-plate", 8} },
    result = IC.MOD_PREFIX.."container"
  },
}
