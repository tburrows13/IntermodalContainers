local IC = require "prototypes.shared"

-- the machines
IC.create_machine_recipe(1, {
	{"engine-unit", 4},
	{"bulk-inserter", 1},
	{"steel-plate", 20},
})

IC.create_machine_recipe(2, {
	{IC.ENTITY_PREFIX.."1", 1},
	{"electric-engine-unit", 2},
	{"bulk-inserter", 2},
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
    results = {{type="item", name=IC.MOD_PREFIX.."container", amount=1}},
  },
}
