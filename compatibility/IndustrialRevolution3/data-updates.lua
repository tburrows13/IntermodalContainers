if not mods["IndustrialRevolution3"] then return end

local IC = require "prototypes.shared"

data.raw.recipe["ic-container"].ingredients = {
    {"steel-plate-heavy", 1},
    {"steel-rivet", 3},
    {"steel-plate", 4}
}

if mods["IndustrialRevolution3LoadersStacking"] then
    data.raw.recipe[IC.ENTITY_PREFIX.."1"].ingredients = {
        {"iron-frame-large", 1},
        {"computer-mk1", 1},
        {"ir3-loader", 2},
        {"ir3-beltbox", 1}
    }
    data.raw.recipe[IC.ENTITY_PREFIX.."2"].ingredients = {
        {"steel-frame-large", 1},
        {"computer-mk2", 1},
        {"ir3-fast-loader", 2},
        {"ir3-fast-beltbox", 1}
    }
    data.raw.recipe[IC.ENTITY_PREFIX.."3"].ingredients = {
        {"chromium-frame-large", 1},
        {"computer-mk3", 1},
        {"ir3-express-loader", 2},
        {"ir3-express-beltbox", 1}
    }
else
    data.raw.recipe[IC.ENTITY_PREFIX.."1"].ingredients = {
        {"iron-frame-large", 1},
        {"computer-mk1", 1},
        {"inserter", 3}
    }
    data.raw.recipe[IC.ENTITY_PREFIX.."2"].ingredients = {
        {"steel-frame-large", 1},
        {"computer-mk2", 1},
        {"fast-inserter", 3}
    }
    data.raw.recipe[IC.ENTITY_PREFIX.."3"].ingredients = {
        {"chromium-frame-large", 1},
        {"computer-mk3", 1},
        {"stack-inserter", 3}
    }
end
