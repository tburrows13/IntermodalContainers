local function divide_inventory_size(prototype, amount)
  if prototype.inventory_size > 2 then
    prototype.inventory_size = math.max(math.ceil(prototype.inventory_size / amount), 2)
  end
end

local inventory_multiplier = settings.startup["ic-cargo-wagon-inventory-multiplier"].value
if inventory_multiplier ~= 1 then
  for _, prototype in pairs(data.raw["cargo-wagon"]) do
    divide_inventory_size(prototype, 1 / inventory_multiplier)
  end
end
