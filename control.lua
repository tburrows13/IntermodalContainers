local handler = require "__core__.lualib.event_handler"

local function on_init()
  for _, force in pairs(game.forces) do
    force.reset_technology_effects()
  end
end

handler.add_lib({
  on_init = on_init,
  on_configuration_changed = on_init
})

handler.add_lib(require "compatibility.krastorio2.control")