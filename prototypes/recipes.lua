local IC = require "prototypes.shared"

-- the machines
IC.create_machine_recipe(1, {
	{"assembling-machine-1", 1},
	{"electric-engine-unit", 1},
	{"stack-inserter", 2},
	{"steel-plate", 20},
})

IC.create_machine_recipe(2, {
	{IC.ENTITY_PREFIX.."1", 1},
	{"electric-engine-unit", 1},
	{"stack-inserter", 2},
	{"steel-plate", 30},
})

IC.create_machine_recipe(3, {
	{IC.ENTITY_PREFIX.."2", 1},
	{"electric-engine-unit", 1},
	{"stack-inserter", 2},
	{"steel-plate", 50},
})

-- crafting tab groups
data:extend({
  -- Pack Group
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
  if subgroup.group == "intermediate-products" then
    data:extend{
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

-- player character can pack and unpack
table.insert(data.raw["character"]["character"].crafting_categories, "packing")
