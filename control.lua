local function on_init()
  for _, force in pairs(game.forces) do
    force.reset_technology_effects()
  end
end

script.on_init(on_init)
script.on_configuration_changed(on_init)