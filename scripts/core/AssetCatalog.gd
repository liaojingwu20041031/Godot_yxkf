extends Node

# Floor tiles
var floors = {
	"sand_stone_0": "res://assets/dungeon_crawl/floor/floor_sand_stone0.png",
	"sand_stone_1": "res://assets/dungeon_crawl/floor/floor_sand_stone1.png",
	"sand_stone_2": "res://assets/dungeon_crawl/floor/floor_sand_stone2.png",
	"cobble_blood_1": "res://assets/dungeon_crawl/floor/cobble_blood1.png",
	"cobble_blood_2": "res://assets/dungeon_crawl/floor/cobble_blood2.png",
	"cobble_blood_3": "res://assets/dungeon_crawl/floor/cobble_blood3.png",
	"cobble_blood_4": "res://assets/dungeon_crawl/floor/cobble_blood4.png",
	"dirt": "res://assets/dungeon_crawl/floor/dirt0.png",
}

# Wall tiles
var walls = {
	"brick_brown_0": "res://assets/dungeon_crawl/wall/brick_brown0.png",
	"brick_brown_1": "res://assets/dungeon_crawl/wall/brick_brown1.png",
	"brick_brown_2": "res://assets/dungeon_crawl/wall/brick_brown2.png",
	"brick_brown_3": "res://assets/dungeon_crawl/wall/brick_brown3.png",
	"brick_dark_0": "res://assets/dungeon_crawl/wall/brick_dark0.png",
	"brick_dark_1": "res://assets/dungeon_crawl/wall/brick_dark1.png",
	"brick_dark_2": "res://assets/dungeon_crawl/wall/brick_dark2.png",
	"brick_dark_3": "res://assets/dungeon_crawl/wall/brick_dark3.png",
}

# Doors
var doors = {
	"closed": "res://assets/dungeon_crawl/doors/dngn_closed_door.png",
	"open": "res://assets/dungeon_crawl/doors/dngn_open_door.png",
}

# Decorations
var decorations = {
	"barrel": "res://assets/dungeon_crawl/decorations/barrel.png",
	"boulder": "res://assets/dungeon_crawl/decorations/boulder.png",
	"crumbled_column": "res://assets/dungeon_crawl/decorations/crumbled_column.png",
	"granite_statue": "res://assets/dungeon_crawl/decorations/granite_statue.png",
	"pillar": "res://assets/dungeon_crawl/decorations/pillar.png",
	"portal": "res://assets/dungeon_crawl/decorations/portal.png",
	"torch_0": "res://assets/dungeon_crawl/decorations/torch_0.png",
	"torch_1": "res://assets/dungeon_crawl/decorations/torch_1.png",
	"torch_2": "res://assets/dungeon_crawl/decorations/torch_2.png",
	"torch_3": "res://assets/dungeon_crawl/decorations/torch_3.png",
	"torch_4": "res://assets/dungeon_crawl/decorations/torch_4.png",
	"trap_spear": "res://assets/dungeon_crawl/decorations/trap_spear.png",
}

# Chests
var chests = {
	"closed": "res://assets/dungeon_crawl/items/misc/chest_closed.png",
	"open": "res://assets/dungeon_crawl/items/misc/chest_open.png",
}

# Potions
var potions = {
	"brilliant_blue": "res://assets/dungeon_crawl/items/potions/brilliant_blue.png",
	"emerald": "res://assets/dungeon_crawl/items/potions/emerald.png",
	"blood": "res://assets/dungeon_crawl/items/potions/i-blood.png",
}

# Weapons
var weapons = {
	"battle_axe": "res://assets/dungeon_crawl/items/weapons/battle_axe1.png",
	"blessed_blade": "res://assets/dungeon_crawl/items/weapons/blessed_blade.png",
	"long_sword": "res://assets/dungeon_crawl/items/weapons/long_sword1.png",
	"short_sword": "res://assets/dungeon_crawl/items/weapons/short_sword1.png",
}

# Amulets / pendants
var amulets = {
	"cameo_blue": "res://assets/dungeon_crawl/items/misc/cameo_blue.png",
	"cameo_orange": "res://assets/dungeon_crawl/items/misc/cameo_orange.png",
	"celtic_blue": "res://assets/dungeon_crawl/items/misc/celtic_blue.png",
	"celtic_red": "res://assets/dungeon_crawl/items/misc/celtic_red.png",
	"celtic_yellow": "res://assets/dungeon_crawl/items/misc/celtic_yellow.png",
}

# Rings
var rings = {
	"ring_cyan": "res://assets/dungeon_crawl/items/misc/ring_cyan.png",
	"ring_green": "res://assets/dungeon_crawl/items/misc/ring_green.png",
	"ring_red": "res://assets/dungeon_crawl/items/misc/ring_red.png",
}

# Crystals / gems
var crystals = {
	"crystal_green": "res://assets/dungeon_crawl/items/misc/crystal_green.png",
	"crystal_red": "res://assets/dungeon_crawl/items/misc/crystal_red.png",
	"crystal_white": "res://assets/dungeon_crawl/items/misc/crystal_white.png",
}

# Curse / misc icons
var curse_icons = {
	"i-rage": "res://assets/dungeon_crawl/items/misc/i-rage.png",
	"i-inaccuracy": "res://assets/dungeon_crawl/items/misc/i-inaccuracy.png",
	"i-r-corrosion": "res://assets/dungeon_crawl/items/misc/i-r-corrosion.png",
	"i-r-mutation": "res://assets/dungeon_crawl/items/misc/i-r-mutation.png",
}

# Positive misc icons
var blessing_icons = {
	"i-flight": "res://assets/dungeon_crawl/items/misc/i-flight.png",
	"i-clarity": "res://assets/dungeon_crawl/items/misc/i-clarity.png",
	"i-conservation": "res://assets/dungeon_crawl/items/misc/i-conservation.png",
	"i-faith": "res://assets/dungeon_crawl/items/misc/i-faith.png",
	"i-gourmand": "res://assets/dungeon_crawl/items/misc/i-gourmand.png",
	"i-spirit": "res://assets/dungeon_crawl/items/misc/i-spirit.png",
	"i-stasis": "res://assets/dungeon_crawl/items/misc/i-stasis.png",
	"i-warding": "res://assets/dungeon_crawl/items/misc/i-warding.png",
}

# Stones
var stones = {
	"stone1_cyan": "res://assets/dungeon_crawl/items/misc/stone1_cyan.png",
	"stone1_green": "res://assets/dungeon_crawl/items/misc/stone1_green.png",
	"stone1_pink": "res://assets/dungeon_crawl/items/misc/stone1_pink.png",
	"stone2_blue": "res://assets/dungeon_crawl/items/misc/stone2_blue.png",
	"stone2_green": "res://assets/dungeon_crawl/items/misc/stone2_green.png",
	"stone2_red": "res://assets/dungeon_crawl/items/misc/stone2_red.png",
	"stone3_blue": "res://assets/dungeon_crawl/items/misc/stone3_blue.png",
	"stone3_green": "res://assets/dungeon_crawl/items/misc/stone3_green.png",
	"stone3_magenta": "res://assets/dungeon_crawl/items/misc/stone3_magenta.png",
}

# Pentagrams
var pentagrams = {
	"penta_green": "res://assets/dungeon_crawl/items/misc/penta_green.png",
	"penta_orange": "res://assets/dungeon_crawl/items/misc/penta_orange.png",
}

# Misc
var misc = {
	"bone_gray": "res://assets/dungeon_crawl/items/misc/bone_gray.png",
	"cylinder_gray": "res://assets/dungeon_crawl/items/misc/cylinder_gray.png",
	"eye_cyan": "res://assets/dungeon_crawl/items/misc/eye_cyan.png",
	"eye_green": "res://assets/dungeon_crawl/items/misc/eye_green.png",
	"eye_magenta": "res://assets/dungeon_crawl/items/misc/eye_magenta.png",
	"face1_gold": "res://assets/dungeon_crawl/items/misc/face1_gold.png",
	"face2": "res://assets/dungeon_crawl/items/misc/face2.png",
}

# Monsters
var monsters = {
	"skeletal_warrior": "res://assets/dungeon_crawl/monsters/skeletal_warrior.png",
	"giant_bat": "res://assets/dungeon_crawl/monsters/giant_bat.png",
	"jumping_spider": "res://assets/dungeon_crawl/monsters/jumping_spider.png",
	"orc_warrior": "res://assets/dungeon_crawl/monsters/orc_warrior.png",
	"hell_knight": "res://assets/dungeon_crawl/monsters/hell_knight.png",
	"deep_elf_knight": "res://assets/dungeon_crawl/monsters/deep_elf_knight.png",
	"deep_elf_mage": "res://assets/dungeon_crawl/monsters/deep_elf_mage.png",
}

# GUI
var gui = {
	"tab_mouseover": "res://assets/dungeon_crawl/gui/tab_mouseover.png",
	"tab_selected": "res://assets/dungeon_crawl/gui/tab_selected.png",
	"tab_unselected": "res://assets/dungeon_crawl/gui/tab_unselected.png",
}

# Convenience methods
func get_random_floor() -> String:
	var keys = floors.keys()
	return floors[keys[randi() % keys.size()]]

func get_random_wall() -> String:
	var keys = walls.keys()
	return walls[keys[randi() % keys.size()]]

func get_random_decoration() -> String:
	var keys = decorations.keys()
	return decorations[keys[randi() % keys.size()]]

func get_random_weapon() -> String:
	var keys = weapons.keys()
	return weapons[keys[randi() % keys.size()]]

func get_random_potion() -> String:
	var keys = potions.keys()
	return potions[keys[randi() % keys.size()]]

func get_random_amulet() -> String:
	var keys = amulets.keys()
	return amulets[keys[randi() % keys.size()]]

func get_random_ring() -> String:
	var keys = rings.keys()
	return rings[keys[randi() % keys.size()]]

func get_random_monster() -> String:
	var keys = monsters.keys()
	return monsters[keys[randi() % keys.size()]]
