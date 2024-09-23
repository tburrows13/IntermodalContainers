local IC = require "prototypes.shared"

-- the machines
IC.create_machine_recipe(1, {
	{type="item", name="engine-unit", amount=4},
	{type="item", name="bulk-inserter", amount=1},
	{type="item", name="steel-plate", amount=20},
})

IC.create_machine_recipe(2, {
	{type="item", name=IC.ENTITY_PREFIX.."1", amount=1},
	{type="item", name="electric-engine-unit", amount=2},
	{type="item", name="bulk-inserter", amount=2},
	{type="item", name="steel-plate", amount=30},
})

IC.create_machine_recipe(3, {
	{type="item", name=IC.ENTITY_PREFIX.."2", amount=1},
  {type="item", name="electric-engine-unit", amount=8},
  {type="item", name="advanced-circuit", amount=8},
	{type="item", name="steel-plate", amount=40},
})

-- crafting tab groups
data:extend({
  -- Pack Group
  {
    name = "ic-containers",
    order = "y-0",
    type = "item-group",
    icons = {
      {
        icon = IC.P_G_ICONS .. "square/crating-icon-base-128.png",
        icon_size = 128,
      },
      {
        icon = IC.P_G_ICONS .. "square/crating-icon-mask-128.png",
        icon_size = 128,
        tint = IC.TIER_COLOURS[1]
      },
    },
  },
  {
    name = IC.LOAD_PREFIX .. "container",
    order = "y-1",
    type = "item-group",
    icons = {
    {
      icon = IC.P_G_ICONS .. "square/crating-icon-base-128.png",
      icon_size = 128,
    },
    {
      icon = IC.P_G_ICONS .. "square/crating-icon-mask-128.png",
      icon_size = 128,
      tint = IC.TIER_COLOURS[1]
    },
    {
      icon = IC.P_G_ICONS .. "arrow/arrow.png",
      icon_size = 64,
      icon_mipmaps = 1,
      scale = 0.8,
      shift = {0, 0}
    }
    },
  },
  -- Unpack Group
  {
    name = IC.UNLOAD_PREFIX .. "container",
    order = "y-2",
    type = "item-group",
    icons = {
    {
      icon = IC.P_G_ICONS .. "square/crating-icon-base-128.png",
      icon_size = 128,
    },
    {
      icon = IC.P_G_ICONS .. "square/crating-icon-mask-128.png",
      icon_size = 128,
      tint = IC.TIER_COLOURS[1]
    },
    {
      icon = IC.P_G_ICONS .. "arrow/arrow-up.png",
      icon_size = 64,
      icon_mipmaps = 1,
      scale = 0.8,
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
    name = "ic-container",
    enabled = false,
    ingredients = {{type="item", name="steel-plate", amount=8}},
    results = {{type="item", name="ic-container", amount=1}},
  },
}
