if not mods["IndustrialRevolution3"] then return end

local IC = require "prototypes.shared"

data.raw.technology[IC.TECH_PREFIX.."3"].unit.count = 1000

if mods["IndustrialRevolution3LoadersStacking"] then
    data.raw.technology[IC.TECH_PREFIX.."1"].prerequisites = {"ir3-beltbox"}
    data.raw.technology[IC.TECH_PREFIX.."2"].prerequisites = {"ir3-fast-beltbox", "ir-electronics-2", IC.TECH_PREFIX.."1"}
    data.raw.technology[IC.TECH_PREFIX.."3"].prerequisites = {"ir3-express-beltbox", "ir-electronics-3", IC.TECH_PREFIX.."2"}
else
    data.raw.technology[IC.TECH_PREFIX.."1"].prerequisites = {"ir-normal-inserter-capacity-bonus-2", "ir-steel-milestone"}
    data.raw.technology[IC.TECH_PREFIX.."2"].prerequisites = {"ir-inserters-2", "ir-electronics-2", IC.TECH_PREFIX.."1"}
    data.raw.technology[IC.TECH_PREFIX.."3"].prerequisites = {"inserter-capacity-bonus-3", "ir-electronics-3", IC.TECH_PREFIX.."2"}
end
