local function add_radioactive_items()
  if not game.active_mods["Krastorio2"] then return end
  if not (remote.interfaces["kr-radioactivity"] and remote.interfaces["kr-radioactivity"]["add_item"]) then return end

  local IC = "ic-container-"
  for ___, name in pairs({
    -- Vanilla
    "nuclear-fuel",
    "uranium-235",
    "uranium-238",
    "uranium-fuel-cell",
    "uranium-ore",
    "used-up-uranium-fuel-cell",
    -- Plutonium Energy
    "breeder-fuel-cell",
    "plutonium",
    "used-up-breeder-fuel-cell",
    -- Schall Uranium Processing
    "uranium-concentrate",
    "uranium-low-enriched"
  }) do
    if game.item_prototypes[IC..name] ~= nil then
      remote.call("kr-radioactivity", "add_item", IC..name)
    end
  end
end

---@param changed_data ConfigurationChangedData
local function on_configuration_changed(changed_data)
  if not game.active_mods["Krastorio2"] then return end

  if changed_data.mod_changes["Krastorio2"].old_version == nil then
    add_radioactive_items()
  end
end

return {
  on_init = add_radioactive_items,
  on_configuration_changed = on_configuration_changed
}