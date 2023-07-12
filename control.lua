local handler = require "__core__.lualib.event_handler"

local function consistency_test()
  print("Intermodal Containers: Checking recipes")

  local containerisation_recipes = game.get_filtered_recipe_prototypes{{filter = "category", category = "packing"}}

  local checked = 0
  for _, recipe in pairs(containerisation_recipes) do
    local recipe_name = recipe.name
    if recipe_name:sub(1, 8) == "ic-load-" then
      local expected_name = recipe.name:sub(9, -1)
      local actual_ingredient = recipe.ingredients[1]
      if actual_ingredient.name == "ic-container" then
        actual_ingredient = recipe.ingredients[2]
      end
      local actual_name = actual_ingredient.name
      if expected_name ~= actual_name then
        log("Intermodal Containers: Loading recipe " .. recipe.name .. " has unexpected ingredient " .. actual_name .. " (expected " .. expected_name .. ")")
      end
    else
      local expected_name = recipe.name:sub(11, -1)
      local actual_product = recipe.products[1]
      if actual_product.name == "ic-container" then
        actual_product = recipe.products[2]
      end
      local actual_name = actual_product.name
      if expected_name ~= actual_name then
        log("Intermodal Containers: Unloading recipe " .. recipe.name .. " has unexpected product " .. actual_name .. " (expected " .. expected_name .. ")")
      end
    end
    checked = checked + 1
  end

  print("Intermodal Containers: Checked " .. checked .. " recipes")
end

local function on_init()
  for _, force in pairs(game.forces) do
    force.reset_technology_effects()
  end
  consistency_test()
end

handler.add_lib({
  on_init = on_init,
  on_configuration_changed = on_init
})

handler.add_lib(require "compatibility.krastorio2.control")