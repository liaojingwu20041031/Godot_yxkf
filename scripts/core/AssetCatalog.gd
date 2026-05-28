extends Node

# Floor tiles
var floors = {
	"sand_stone_0": "res://assets/dungeon_crawl/floor/floor_sand_stone0.png",
	"sand_stone_1": "res://assets/dungeon_crawl/floor/floor_sand_stone1.png",
	"sand_stone_2": "res://assets/dungeon_crawl/floor/floor_sand_stone2.png",
	"sand_stone_3": "res://assets/dungeon_crawl/floor/floor_sand_stone_3.png",
	"sand_stone_4": "res://assets/dungeon_crawl/floor/floor_sand_stone_4.png",
	"sand_stone_5": "res://assets/dungeon_crawl/floor/floor_sand_stone_5.png",
	"sand_stone_6": "res://assets/dungeon_crawl/floor/floor_sand_stone_6.png",
	"sand_stone_7": "res://assets/dungeon_crawl/floor/floor_sand_stone_7.png",
	"cobble_blood_1": "res://assets/dungeon_crawl/floor/cobble_blood1.png",
	"cobble_blood_2": "res://assets/dungeon_crawl/floor/cobble_blood2.png",
	"cobble_blood_3": "res://assets/dungeon_crawl/floor/cobble_blood3.png",
	"cobble_blood_4": "res://assets/dungeon_crawl/floor/cobble_blood4.png",
	"limestone_0": "res://assets/dungeon_crawl/floor/limestone_0.png",
	"limestone_1": "res://assets/dungeon_crawl/floor/limestone_1.png",
	"limestone_2": "res://assets/dungeon_crawl/floor/limestone_2.png",
	"limestone_3": "res://assets/dungeon_crawl/floor/limestone_3.png",
	"crypt_10": "res://assets/dungeon_crawl/floor/crypt_10.png",
	"crypt_11": "res://assets/dungeon_crawl/floor/crypt_11.png",
	"acidic_floor_0": "res://assets/dungeon_crawl/floor/acidic_floor_0.png",
	"dirt": "res://assets/dungeon_crawl/floor/dirt0.png",
}

# Wall tiles
var walls = {
	"brick_brown_0": "res://assets/dungeon_crawl/wall/brick_brown0.png",
	"brick_brown_1": "res://assets/dungeon_crawl/wall/brick_brown1.png",
	"brick_brown_2": "res://assets/dungeon_crawl/wall/brick_brown2.png",
	"brick_brown_3": "res://assets/dungeon_crawl/wall/brick_brown3.png",
	"brick_brown_4": "res://assets/dungeon_crawl/wall/brick_brown_4.png",
	"brick_brown_5": "res://assets/dungeon_crawl/wall/brick_brown_5.png",
	"brick_brown_6": "res://assets/dungeon_crawl/wall/brick_brown_6.png",
	"brick_brown_7": "res://assets/dungeon_crawl/wall/brick_brown_7.png",
	"brick_dark_0": "res://assets/dungeon_crawl/wall/brick_dark0.png",
	"brick_dark_1": "res://assets/dungeon_crawl/wall/brick_dark1.png",
	"brick_dark_2": "res://assets/dungeon_crawl/wall/brick_dark2.png",
	"brick_dark_3": "res://assets/dungeon_crawl/wall/brick_dark3.png",
	"brick_dark_4": "res://assets/dungeon_crawl/wall/brick_dark_4.png",
	"brick_dark_5": "res://assets/dungeon_crawl/wall/brick_dark_5.png",
	"brick_dark_6": "res://assets/dungeon_crawl/wall/brick_dark_6.png",
	"stone_gray_0": "res://assets/dungeon_crawl/wall/stone_gray_0.png",
	"stone_gray_1": "res://assets/dungeon_crawl/wall/stone_gray_1.png",
	"stone_gray_2": "res://assets/dungeon_crawl/wall/stone_gray_2.png",
	"stone_gray_3": "res://assets/dungeon_crawl/wall/stone_gray_3.png",
}

# Doors
var doors = {
	"closed": "res://assets/dungeon_crawl/doors/dngn_closed_door.png",
	"open": "res://assets/dungeon_crawl/doors/dngn_open_door.png",
	"runed": "res://assets/dungeon_crawl/doors/runed_door.png",
	"sealed": "res://assets/dungeon_crawl/doors/sealed_door.png",
	"secret": "res://assets/dungeon_crawl/doors/detected_secret_door.png",
	"gate_closed_left": "res://assets/dungeon_crawl/doors/gate_closed_left.png",
	"gate_closed_middle": "res://assets/dungeon_crawl/doors/gate_closed_middle.png",
	"gate_closed_right": "res://assets/dungeon_crawl/doors/gate_closed_right.png",
}

# Decorations
var decorations = {
	"barrel": "res://assets/dungeon_crawl/decorations/barrel.png",
	"boulder": "res://assets/dungeon_crawl/decorations/boulder.png",
	"crumbled_column": "res://assets/dungeon_crawl/decorations/crumbled_column.png",
	"granite_statue": "res://assets/dungeon_crawl/decorations/granite_statue.png",
	"pillar": "res://assets/dungeon_crawl/decorations/pillar.png",
	"portal": "res://assets/dungeon_crawl/decorations/portal.png",
	"banner": "res://assets/dungeon_crawl/decorations/banner_1.png",
	"blue_fountain": "res://assets/dungeon_crawl/decorations/blue_fountain.png",
	"dry_fountain": "res://assets/dungeon_crawl/decorations/dry_fountain.png",
	"large_box": "res://assets/dungeon_crawl/decorations/large_box.png",
	"sarcophagus_open": "res://assets/dungeon_crawl/decorations/sarcophagus_open.png",
	"mold_large_1": "res://assets/dungeon_crawl/decorations/mold_large_1.png",
	"mold_large_2": "res://assets/dungeon_crawl/decorations/mold_large_2.png",
	"torch_0": "res://assets/dungeon_crawl/decorations/torch_0.png",
	"torch_1": "res://assets/dungeon_crawl/decorations/torch_1.png",
	"torch_2": "res://assets/dungeon_crawl/decorations/torch_2.png",
	"torch_3": "res://assets/dungeon_crawl/decorations/torch_3.png",
	"torch_4": "res://assets/dungeon_crawl/decorations/torch_4.png",
	"trap_spear": "res://assets/dungeon_crawl/decorations/trap_spear.png",
}

var traps = {
	"alarm": "res://assets/dungeon_crawl/traps/alarm.png",
	"gas": "res://assets/dungeon_crawl/traps/gas_trap.png",
	"pressure_plate": "res://assets/dungeon_crawl/traps/pressure_plate.png",
	"shaft": "res://assets/dungeon_crawl/traps/shaft.png",
	"teleport": "res://assets/dungeon_crawl/traps/teleport_permanent.png",
	"arrow": "res://assets/dungeon_crawl/traps/trap_arrow.png",
	"axe": "res://assets/dungeon_crawl/traps/trap_axe.png",
	"blade": "res://assets/dungeon_crawl/traps/trap_blade.png",
	"dart": "res://assets/dungeon_crawl/traps/trap_dart.png",
	"net": "res://assets/dungeon_crawl/traps/trap_net.png",
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
	"clear": "res://assets/dungeon_crawl/items/potions/clear.png",
	"golden": "res://assets/dungeon_crawl/items/potions/golden.png",
	"murky": "res://assets/dungeon_crawl/items/potions/murky.png",
	"ruby": "res://assets/dungeon_crawl/items/potions/ruby_new.png",
	"sky_blue": "res://assets/dungeon_crawl/items/potions/sky_blue.png",
}

# Weapons
var weapons = {
	"battle_axe": "res://assets/dungeon_crawl/items/weapons/battle_axe1.png",
	"blessed_blade": "res://assets/dungeon_crawl/items/weapons/blessed_blade.png",
	"axe": "res://assets/dungeon_crawl/items/weapons/axe.png",
	"bow": "res://assets/dungeon_crawl/items/weapons/bow_1.png",
	"club": "res://assets/dungeon_crawl/items/weapons/club_new.png",
	"crossbow": "res://assets/dungeon_crawl/items/weapons/crossbow_1.png",
	"dagger": "res://assets/dungeon_crawl/items/weapons/dagger_new.png",
	"flail": "res://assets/dungeon_crawl/items/weapons/flail_1_new.png",
	"long_sword": "res://assets/dungeon_crawl/items/weapons/long_sword1.png",
	"short_sword": "res://assets/dungeon_crawl/items/weapons/short_sword1.png",
	"throwing_net": "res://assets/dungeon_crawl/items/weapons/throwing_net.png",
}

var armor = {
	"buckler": "res://assets/dungeon_crawl/items/armor/buckler_1_new.png",
	"helmet": "res://assets/dungeon_crawl/items/armor/helmet_1.png",
	"leather_armor": "res://assets/dungeon_crawl/items/armor/leather_armor_1.png",
	"ring_mail": "res://assets/dungeon_crawl/items/armor/ring_mail_1_new.png",
	"robe": "res://assets/dungeon_crawl/items/armor/robe_1_new.png",
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
	"i-flight": "res://assets/dungeon_crawl/items/misc/i-c-flight.png",
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
	"apple": "res://assets/dungeon_crawl/items/misc/apple.png",
	"bread": "res://assets/dungeon_crawl/items/misc/bread_ration_new.png",
	"cylinder_gray": "res://assets/dungeon_crawl/items/misc/cylinder_gray.png",
	"eye_cyan": "res://assets/dungeon_crawl/items/misc/eye_cyan.png",
	"eye_green": "res://assets/dungeon_crawl/items/misc/eye_green.png",
	"eye_magenta": "res://assets/dungeon_crawl/items/misc/eye_magenta.png",
	"face1_gold": "res://assets/dungeon_crawl/items/misc/face1_gold.png",
	"face2": "res://assets/dungeon_crawl/items/misc/face2.png",
	"key": "res://assets/dungeon_crawl/items/misc/key.png",
	"lantern": "res://assets/dungeon_crawl/items/misc/misc_lantern.png",
	"scroll_blue": "res://assets/dungeon_crawl/items/misc/scroll-blue.png",
	"scroll_green": "res://assets/dungeon_crawl/items/misc/scroll-green.png",
	"scroll_red": "res://assets/dungeon_crawl/items/misc/scroll-red.png",
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
	"adder": "res://assets/dungeon_crawl/monsters/adder.png",
	"bat": "res://assets/dungeon_crawl/monsters/bat.png",
	"ghost": "res://assets/dungeon_crawl/monsters/ghost_new.png",
	"giant_frog": "res://assets/dungeon_crawl/monsters/giant_frog.png",
	"hound": "res://assets/dungeon_crawl/monsters/hound.png",
	"jelly": "res://assets/dungeon_crawl/monsters/jelly.png",
	"jumping_spider_new": "res://assets/dungeon_crawl/monsters/jumping_spider_new.png",
	"kobold": "res://assets/dungeon_crawl/monsters/kobold_new.png",
	"mummy": "res://assets/dungeon_crawl/monsters/mummy.png",
	"ooze": "res://assets/dungeon_crawl/monsters/ooze_new.png",
	"orc": "res://assets/dungeon_crawl/monsters/orc_new.png",
	"orc_priest": "res://assets/dungeon_crawl/monsters/orc_priest_new.png",
	"orc_wizard": "res://assets/dungeon_crawl/monsters/orc_wizard_new.png",
	"wight": "res://assets/dungeon_crawl/monsters/wight_new.png",
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

func get_random_trap() -> String:
	var keys = traps.keys()
	return traps[keys[randi() % keys.size()]]

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
