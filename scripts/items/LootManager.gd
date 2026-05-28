extends Node

var loot_table: Dictionary = {}

func _ready():
	_init_loot_table()

func _init_loot_table():
	loot_table = {
		"gold": {"type": "currency", "min": 5, "max": 20},
		"key": {"type": "key", "chance": 0.15},
		"small_potion": {"type": "consumable", "chance": 0.4, "heal": 25},
		"big_potion": {"type": "consumable", "chance": 0.15, "heal": 60},
		"shield_potion": {"type": "consumable", "chance": 0.1, "shield": 40},
		"iron_sword": {"type": "equipment", "chance": 0.2, "slot": "weapon", "attack": 3},
		"knight_sword": {"type": "equipment", "chance": 0.08, "slot": "weapon", "attack": 6},
		"leather_armor": {"type": "equipment", "chance": 0.15, "slot": "armor", "defense": 3},
		"chain_armor": {"type": "equipment", "chance": 0.06, "slot": "armor", "defense": 6},
		"health_amulet": {"type": "equipment", "chance": 0.1, "slot": "amulet", "max_health": 15}
	}

func roll_loot(enemy_type: String = "normal") -> Array:
	var drops = []
	var gold_amount = randi_range(5, 15)
	if enemy_type == "elite":
		gold_amount *= 2
	elif enemy_type == "boss":
		gold_amount *= 5
	drops.append({"type": "gold", "amount": gold_amount})

	for item_id in loot_table:
		var item = loot_table[item_id]
		if item["type"] == "currency":
			continue
		var chance = item.get("chance", 0.0)
		if enemy_type == "elite":
			chance *= 1.5
		elif enemy_type == "boss":
			chance *= 2.0
		if randf() < chance:
			drops.append({"id": item_id, "data": item})
			break

	return drops
