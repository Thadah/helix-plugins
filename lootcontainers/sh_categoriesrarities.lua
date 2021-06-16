--This file is for setting different item categories and the rarities in which those categories will spawn
local PLUGIN = PLUGIN

PLUGIN.category = {}
PLUGIN.rarity = {}

--------CATEGORIES--------

PLUGIN.category["drinks"] = {
    "water_breen",
    "water_sparkling"
}

PLUGIN.category["medical"] = {
    "health_vial"
}


PLUGIN.category["powerups"] = {
    "item_battery"
}

PLUGIN.category["weapons"] = {
    "weapon_crowbar"
}

--------RARITIES--------

PLUGIN.rarity["common"] = {
    1,
    {
        "drinks"
    }
}

PLUGIN.rarity["uncommon"] = {
    0.75,
    {
        "drinks"
    }
}

PLUGIN.rarity["rare"] = {
    0.15,
    {
        "medical"
    }
}

PLUGIN.rarity["exotic"] = {
    0.05,
    {
        "medical",
        "powerups"
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