--This file is for setting different item categories and the rarities in which those categories will spawn
local PLUGIN = PLUGIN

PLUGIN.category = {}
PLUGIN.rarity = {}

--------CATEGORIES--------

PLUGIN.category["drinks"] = {
    "botella_agua_sucia"
}

PLUGIN.category["medical"] = {
    "bandage",
    "health_vial"
}

PLUGIN.category["food"] = {
    "headcrabfillet",
    "vortigauntfillet"
}

PLUGIN.category["junk"] = {
    "shoe",
    "scrap_electronics",
    "charred_metal",
    "battered_scrap",
    "wooden_piece",
    "metal_piece",
    "empty_beer",
    "empty_metal_can",
    "empty_milk_carton",
    "empty_replacement_beer",
    "oil_bottle",
    "plastic_bottle",
    "empty_can",
    "plank",
    "bullet_casings",
    "cloth_scrap",
    "empty_ammunition_case",
    "flammable_oxygen",
    "gunpowder",
    "smg_empty_box",
    "steel_scrap",
    "glue",
    "rubber",
    "aluminum",
    "plastic_piece",
    "junkwood",
    "journal_three",
    "broken_doll"
}

PLUGIN.category["powerups"] = {
    "item_battery",
    "grease",
    "firearm_mechanism",
    "metropolice_mask",
    "refined_metal",
    "explosives"
}

PLUGIN.category["weapons"] = {
    "pan",
    "metalscrewdriver",
    "tfanmrihmelee15wrench",
    "tfanmrihmelee3bcd",
    "guns_oil"
}

--------RARITIES--------

PLUGIN.rarity["common"] = {
    1,
    {
        "junk"
    }
}

PLUGIN.rarity["uncommon"] = {
    0.75,
    {
        "drinks",
        "food"
    }
}

PLUGIN.rarity["rare"] = {
    0.15,
    {
        "powerups"
    }
}

PLUGIN.rarity["exotic"] = {
    0.05,
    {
        "medical"
    }
}

PLUGIN.rarity["precious"] = {
    0.01,
    {
        "weapons"
    }
}

PLUGIN.rarity["unobtainium"] = {
    0.001,
    {
        "weapons"
    }
}