local IC = require "prototypes.shared"
-- Create item subgroups
for name, subgroup in pairs(data.raw["item-subgroup"]) do
  if subgroup.group ~= "ic-containers" and subgroup.group ~= IC.LOAD_PREFIX .. "container" and subgroup.group ~= IC.UNLOAD_PREFIX .. "container" then
    data:extend{
      {
        type  = "item-subgroup",
        name  = "ic-" .. name,
        group = "ic-containers",
        order = "a[container]-" .. (subgroup.order or "unordered"),
      },
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
