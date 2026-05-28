extends Node

# Item texture mapping
const ITEM_TEXTURES = {
	"gold": "res://assets/dungeon_crawl/items/misc/face1_gold.png",
	"key": "res://assets/dungeon_crawl/items/misc/celtic_blue.png",
	"small_potion": "res://assets/dungeon_crawl/items/potions/emerald.png",
	"big_potion": "res://assets/dungeon_crawl/items/potions/brilliant_blue.png",
	"shield_potion": "res://assets/dungeon_crawl/items/potions/i-blood.png",
	"iron_sword": "res://assets/dungeon_crawl/items/weapons/short_sword1.png",
	"knight_sword": "res://assets/dungeon_crawl/items/weapons/long_sword1.png",
	"leather_armor": "res://assets/dungeon_crawl/items/weapons/battle_axe1.png",
	"chain_armor": "res://assets/dungeon_crawl/items/weapons/blessed_blade.png",
	"health_amulet": "res://assets/dungeon_crawl/items/misc/crystal_green.png",
}

static func spawn_loot(drops: Array, position: Vector2, parent: Node):
	for drop_data in drops:
		var item_id = drop_data.get("id", "")
		var item_info = drop_data.get("data", {})
		var drop_type = drop_data.get("type", "")

		var drop_node = Area2D.new()
		drop_node.name = "ItemDrop"
		drop_node.set_script(load("res://scripts/items/ItemDrop.gd"))

		# Create sprite
		var sprite = Sprite2D.new()
		sprite.name = "Sprite2D"

		# Find texture
		var tex_path = ""
		if drop_type == "gold":
			tex_path = ITEM_TEXTURES.get("gold", "")
		elif item_id != "":
			tex_path = ITEM_TEXTURES.get(item_id, "")

		if tex_path != "":
			var tex = load(tex_path)
			if tex:
				sprite.texture = tex
				sprite.scale = Vector2(0.8, 0.8)

		drop_node.add_child(sprite)

		# Create glow light
		var light = PointLight2D.new()
		light.name = "GlowLight"
		light.color = Color(1.0, 0.85, 0.2, 0.8)
		light.energy = 0.5
		light.texture_scale = 0.4
		drop_node.add_child(light)

		# Create collision
		var col = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 10.0
		col.shape = shape
		drop_node.add_child(col)

		parent.add_child(drop_node)

		# Setup item data
		var full_data = drop_data.duplicate()
		full_data["texture"] = tex_path
		if drop_type == "gold":
			full_data["type"] = "gold"
		elif item_info.has("type"):
			full_data["type"] = item_info["type"]

		drop_node.setup(full_data, null, position + Vector2(randf_range(-10, 10), 0))

static func spawn_from_enemy(enemy_position: Vector2, enemy_type: String, parent: Node):
	var loot_manager = parent.get_node_or_null("/root/LootManager")
	if not loot_manager:
		# Create a temporary one
		loot_manager = load("res://scripts/items/LootManager.gd").new()
		parent.add_child(loot_manager)

	var drops = loot_manager.roll_loot(enemy_type)
	spawn_loot(drops, enemy_position, parent)
