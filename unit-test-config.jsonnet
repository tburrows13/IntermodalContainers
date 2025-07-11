local core = ["IntermodalContainers", "remove-animations"];
local SA = ["space-age", "elevated-rails", "quality"];
local K2 = ["Krastorio2", "Krastorio2Assets", "ChangeInserterDropLane", "flib"];
local bobs = ["boblibrary", "bobinserters", "boblogistics", "bobpower", "bobwarfare", "bobassembly", "bobores", "bobmining", "bobplates", "bobenemies", "bobelectronics", "bobmodules", "bobtech", "bobrevamp", "bobvehicleequipment", "bobgreenhouse", "bobequipment"];

{
    default_settings:
    {
        startup: {
        },
    },
    configurations:
    {
        "Base": {mods: core},
        "SA": {mods: core + SA},
        "K2": {mods: core + K2},
        "Bobs": {mods: core + bobs},
    },
    tests:
    {
        "common.*": {},
    },
}