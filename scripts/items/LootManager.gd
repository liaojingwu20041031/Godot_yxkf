extends Node

var loot_table: Dictionary = {}

func _ready():
	_init_loot_table()

func _init_loot_table():
	loot_table = {
		# === CURRENCY ===
		"gold": {"type": "currency", "min": 5, "max": 20},
		"key": {"type": "key", "chance": 0.15},

		# === CONSUMABLES (8 items) ===
		"small_potion": {"type": "consumable", "chance": 0.35, "heal": 25, "name": "小药水",
			"texture": "res://assets/dungeon_crawl/items/potions/emerald.png"},
		"big_potion": {"type": "consumable", "chance": 0.15, "heal": 60, "name": "大药水",
			"texture": "res://assets/dungeon_crawl/items/potions/brilliant_blue.png"},
		"blood_potion": {"type": "consumable", "chance": 0.10, "heal": 100, "name": "鲜血药水",
			"texture": "res://assets/dungeon_crawl/items/potions/i-blood.png"},
		"shield_potion": {"type": "consumable", "chance": 0.10, "shield": 40, "name": "护盾药水",
			"texture": "res://assets/dungeon_crawl/items/potions/sky_blue.png"},
		"golden_potion": {"type": "consumable", "chance": 0.08, "heal": 20, "shield": 20, "name": "金色药水",
			"texture": "res://assets/dungeon_crawl/items/potions/golden.png"},
		"ruby_potion": {"type": "consumable", "chance": 0.06, "heal": 75, "name": "红宝石药水",
			"texture": "res://assets/dungeon_crawl/items/potions/ruby_new.png"},
		"crystal_green": {"type": "consumable", "chance": 0.08, "heal": 30, "name": "绿色水晶",
			"texture": "res://assets/dungeon_crawl/items/misc/crystal_green.png"},
		"crystal_red": {"type": "consumable", "chance": 0.06, "heal": 50, "name": "红色水晶",
			"texture": "res://assets/dungeon_crawl/items/misc/crystal_red.png"},
		"crystal_white": {"type": "consumable", "chance": 0.04, "heal": 80, "name": "白色水晶",
			"texture": "res://assets/dungeon_crawl/items/misc/crystal_white.png"},
		"stone_cyan": {"type": "consumable", "chance": 0.05, "shield": 60, "name": "青色宝石",
			"texture": "res://assets/dungeon_crawl/items/misc/stone1_cyan.png"},

		# === WEAPONS (10 items) ===
		"short_sword": {"type": "equipment", "chance": 0.18, "slot": "weapon", "attack": 2, "name": "短剑",
			"texture": "res://assets/dungeon_crawl/items/weapons/short_sword1.png"},
		"iron_sword": {"type": "equipment", "chance": 0.14, "slot": "weapon", "attack": 4, "name": "铁剑",
			"texture": "res://assets/dungeon_crawl/items/weapons/short_sword1.png"},
		"long_sword": {"type": "equipment", "chance": 0.10, "slot": "weapon", "attack": 6, "name": "长剑",
			"texture": "res://assets/dungeon_crawl/items/weapons/long_sword1.png"},
		"blessed_blade": {"type": "equipment", "chance": 0.06, "slot": "weapon", "attack": 8, "name": "祝福之刃",
			"texture": "res://assets/dungeon_crawl/items/weapons/blessed_blade.png"},
		"battle_axe": {"type": "equipment", "chance": 0.08, "slot": "weapon", "attack": 7, "name": "战斧",
			"texture": "res://assets/dungeon_crawl/items/weapons/battle_axe1.png"},
		"flame_sword": {"type": "equipment", "chance": 0.04, "slot": "weapon", "attack": 5, "element": "fire", "name": "烈焰剑",
			"texture": "res://assets/dungeon_crawl/items/weapons/blessed_blade.png"},
		"ice_dagger": {"type": "equipment", "chance": 0.05, "slot": "weapon", "attack": 3, "element": "ice", "name": "冰霜匕首",
			"texture": "res://assets/dungeon_crawl/items/weapons/dagger_new.png"},
		"shadow_blade": {"type": "equipment", "chance": 0.03, "slot": "weapon", "attack": 9, "name": "暗影之刃",
			"texture": "res://assets/dungeon_crawl/items/weapons/blessed_blade.png"},
		"bone_club": {"type": "equipment", "chance": 0.12, "slot": "weapon", "attack": 3, "name": "骨棒",
			"texture": "res://assets/dungeon_crawl/items/weapons/club_new.png"},
		"raider_axe": {"type": "equipment", "chance": 0.07, "slot": "weapon", "attack": 5, "name": "掠夺者斧",
			"texture": "res://assets/dungeon_crawl/items/weapons/axe.png"},
		"crystal_staff": {"type": "equipment", "chance": 0.04, "slot": "weapon", "attack": 6, "attack_speed": 0.06, "name": "水晶法杖",
			"texture": "res://assets/dungeon_crawl/items/weapons/flail_1_new.png"},

		# === ARMOR (6 items) ===
		"leather_armor": {"type": "equipment", "chance": 0.12, "slot": "armor", "defense": 2, "name": "皮甲",
			"texture": "res://assets/dungeon_crawl/items/armor/leather_armor_1.png"},
		"chain_armor": {"type": "equipment", "chance": 0.08, "slot": "armor", "defense": 4, "name": "锁甲",
			"texture": "res://assets/dungeon_crawl/items/armor/ring_mail_1_new.png"},
		"plate_armor": {"type": "equipment", "chance": 0.04, "slot": "armor", "defense": 7, "name": "板甲",
			"texture": "res://assets/dungeon_crawl/items/armor/buckler_1_new.png"},
		"shadow_cloak": {"type": "equipment", "chance": 0.05, "slot": "armor", "defense": 3, "speed": 20, "name": "暗影斗篷",
			"texture": "res://assets/dungeon_crawl/items/armor/robe_1_new.png"},
		"fire_robe": {"type": "equipment", "chance": 0.04, "slot": "armor", "defense": 2, "element": "fire", "name": "火焰长袍",
			"texture": "res://assets/dungeon_crawl/items/misc/stone2_red.png"},
		"bone_armor": {"type": "equipment", "chance": 0.06, "slot": "armor", "defense": 5, "name": "骨甲",
			"texture": "res://assets/dungeon_crawl/items/misc/bone_gray.png"},

		# === AMULETS (8 items) ===
		"health_amulet": {"type": "equipment", "chance": 0.08, "slot": "amulet", "max_health": 15, "name": "生命护符",
			"texture": "res://assets/dungeon_crawl/items/misc/cameo_blue.png"},
		"fire_amulet": {"type": "equipment", "chance": 0.06, "slot": "amulet", "element": "fire", "name": "火焰护符",
			"texture": "res://assets/dungeon_crawl/items/misc/cameo_orange.png"},
		"ice_amulet": {"type": "equipment", "chance": 0.05, "slot": "amulet", "element": "ice", "name": "冰霜护符",
			"texture": "res://assets/dungeon_crawl/items/misc/stone1_cyan.png"},
		"blood_amulet": {"type": "equipment", "chance": 0.04, "slot": "amulet", "lifesteal": 0.1, "name": "鲜血护符",
			"texture": "res://assets/dungeon_crawl/items/misc/celtic_red.png"},
		"shadow_amulet": {"type": "equipment", "chance": 0.03, "slot": "amulet", "speed": 15, "name": "暗影护符",
			"texture": "res://assets/dungeon_crawl/items/misc/stone3_magenta.png"},
		"celtic_blue": {"type": "equipment", "chance": 0.06, "slot": "amulet", "max_health": 10, "name": "蓝色凯尔特护符",
			"texture": "res://assets/dungeon_crawl/items/misc/celtic_blue.png"},
		"celtic_yellow": {"type": "equipment", "chance": 0.05, "slot": "amulet", "gold_bonus": 0.2, "name": "金色凯尔特护符",
			"texture": "res://assets/dungeon_crawl/items/misc/celtic_yellow.png"},
		"eye_amulet": {"type": "equipment", "chance": 0.03, "slot": "amulet", "detection": 50, "name": "鹰眼护符",
			"texture": "res://assets/dungeon_crawl/items/misc/eye_cyan.png"},

		# === RINGS (6 items) ===
		"ring_cyan": {"type": "equipment", "chance": 0.06, "slot": "ring", "defense": 2, "name": "青色戒指",
			"texture": "res://assets/dungeon_crawl/items/misc/ring_cyan.png"},
		"ring_green": {"type": "equipment", "chance": 0.05, "slot": "ring", "max_health": 10, "name": "绿色戒指",
			"texture": "res://assets/dungeon_crawl/items/misc/ring_green.png"},
		"ring_red": {"type": "equipment", "chance": 0.04, "slot": "ring", "attack": 2, "name": "红色戒指",
			"texture": "res://assets/dungeon_crawl/items/misc/ring_red.png"},
		"penta_green": {"type": "equipment", "chance": 0.03, "slot": "ring", "lifesteal": 0.05, "name": "绿色五芒星",
			"texture": "res://assets/dungeon_crawl/items/misc/penta_green.png"},
		"penta_orange": {"type": "equipment", "chance": 0.03, "slot": "ring", "element": "fire", "name": "橙色五芒星",
			"texture": "res://assets/dungeon_crawl/items/misc/penta_orange.png"},
		"face_gold": {"type": "equipment", "chance": 0.02, "slot": "ring", "gold_bonus": 0.5, "name": "黄金面具",
			"texture": "res://assets/dungeon_crawl/items/misc/face1_gold.png"},
		"warding_rune": {"type": "equipment", "chance": 0.04, "slot": "rune", "shield": 20, "defense": 1, "name": "守护符文",
			"texture": "res://assets/dungeon_crawl/items/misc/i-warding.png"},
		"rage_rune": {"type": "equipment", "chance": 0.035, "slot": "rune", "attack": 3, "attack_speed": 0.08, "name": "狂怒符文",
			"texture": "res://assets/dungeon_crawl/items/misc/i-rage.png"},
		"spirit_rune": {"type": "equipment", "chance": 0.035, "slot": "rune", "max_health": 8, "lifesteal": 0.04, "name": "灵魂符文",
			"texture": "res://assets/dungeon_crawl/items/misc/i-spirit.png"},
	}

	for item_id in loot_table:
		var item = loot_table[item_id]
		if item.get("type", "") == "equipment":
			item["stats"] = _extract_item_stats(item)

func _extract_item_stats(item: Dictionary) -> Dictionary:
	var stats = {}
	for stat in ["attack", "attack_power", "defense", "max_health", "shield", "gold_bonus", "lifesteal", "attack_speed", "speed"]:
		if item.has(stat):
			stats[stat] = item[stat]
	return stats

func _build_drop_data(item_id: String, item: Dictionary) -> Dictionary:
	var item_copy = item.duplicate(true)
	item_copy["type"] = item.get("type", "")
	item_copy["name"] = item.get("name", item_id)
	item_copy["texture"] = item.get("texture", "")
	if item_copy.get("type", "") == "equipment" and not item_copy.has("stats"):
		item_copy["stats"] = _extract_item_stats(item_copy)

	var drop_data = {"id": item_id, "data": item_copy}
	for key in item_copy:
		drop_data[key] = item_copy[key]
	return drop_data

func roll_loot(enemy_type: String = "normal") -> Array:
	var drops = []
	var gold_amount = randi_range(5, 15)
	if enemy_type == "elite":
		gold_amount *= 2
	elif enemy_type == "boss":
		gold_amount *= 5
	drops.append({"type": "gold", "amount": gold_amount})

	# Roll for items
	var max_drops = 1
	if enemy_type == "elite":
		max_drops = 2
	elif enemy_type == "boss":
		max_drops = 3

	var dropped_count = 0
	var shuffled_ids = loot_table.keys()
	shuffled_ids.shuffle()

	for item_id in shuffled_ids:
		if dropped_count >= max_drops:
			break
		var item = loot_table[item_id]
		if item["type"] == "currency":
			continue
		var chance = item.get("chance", 0.0)
		if enemy_type == "elite":
			chance *= 1.5
		elif enemy_type == "boss":
			chance *= 2.0
		if randf() < chance:
			drops.append(_build_drop_data(item_id, item))
			dropped_count += 1

	return drops

func roll_chest_loot(chest_type: String = "normal") -> Array:
	var drops = []
	var gold_amount = randi_range(20, 50)
	if chest_type == "rare":
		gold_amount *= 2
	elif chest_type == "cursed":
		gold_amount = 0
	drops.append({"type": "gold", "amount": gold_amount})

	# Chest always drops something
	var item_ids = loot_table.keys()
	item_ids.shuffle()
	for item_id in item_ids:
		var item = loot_table[item_id]
		if item["type"] == "currency":
			continue
		var chance = item.get("chance", 0.0) * 2.0  # Double chance from chests
		if chest_type == "rare":
			chance *= 2.0
		if randf() < chance:
			drops.append(_build_drop_data(item_id, item))
			break

	return drops
