local item_sounds = require("__base__.prototypes.item_sounds")

local IC = require "prototypes.shared"

-- crating machines
for tier = 1,IC.TIERS do
	IC.create_machine_item(tier)
end

data:extend{
  {
    type = "item",
    name = "ic-container",
    icon = IC.P_G_ICONS .. "container/container.png",
    icon_size = 64,
    subgroup = "intermediate-product",
    order = "[first-in-order]",
    stack_size = 10,
    pictures =
    {  -- Oversized on belts and ground 
      {
      filename = IC.P_G_ICONS .. "container/container.png",
      size = 64,
      scale = 0.5 * IC.CONTAINER_PICTURE_SCALE,
      },
    },
    inventory_move_sound = item_sounds.metal_chest_inventory_move,
    pick_sound = item_sounds.metal_chest_inventory_pickup,
    drop_sound = item_sounds.metal_chest_inventory_move,
  },
}