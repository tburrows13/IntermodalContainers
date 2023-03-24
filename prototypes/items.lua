local IC = require "prototypes.shared"

-- crating machines
for tier = 1,IC.TIERS do
	IC.create_machine_item(tier)
end

data:extend{
  {
  type = "item",
  name = IC.MOD_PREFIX .. "container",
  icon = IC.P_G_ICONS .. "container/container.png",
  icon_size = 64, icon_mipmaps = 1,
  subgroup = "intermediate-product",
  order = "[first-in-order]",
  stack_size = 10,
  pictures = 
  {  -- Oversized on belts and ground 
    {
    filename = IC.P_G_ICONS .. "container/container.png",
    size = 64,
    scale = 0.5,
    },
  },
  },
}