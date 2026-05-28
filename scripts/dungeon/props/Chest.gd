extends Node2D

signal opened

enum ChestType { NORMAL, EQUIPMENT, CURSED, KEY }

@export var chest_type: ChestType = ChestType.NORMAL
@export var gold_amount: int = 30

var is_opened: bool = false
var player_nearby: bool = false

@onready var chest_area: Area2D = $ChestArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $InteractLabel

var closed_texture: Texture2D
var open_texture: Texture2D

func _ready():
	closed_texture = load(AssetCatalog.chests["closed"])
	open_texture = load(AssetCatalog.chests["open"])
	if closed_texture and sprite:
		sprite.texture = closed_texture
	if label:
		label.visible = false
	chest_area.body_entered.connect(_on_body_entered)
	chest_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_nearby = true
		if not is_opened and label:
			label.visible = true
			match chest_type:
				ChestType.NORMAL:
					label.text = "E 打开宝箱"
				ChestType.EQUIPMENT:
					label.text = "E 打开装备宝箱"
				ChestType.CURSED:
					label.text = "E 打开诅咒宝箱?"
				ChestType.KEY:
					if GameManager.keys > 0:
						label.text = "E 用钥匙打开"
					else:
						label.text = "需要钥匙"

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_nearby = false
		if label:
			label.visible = false

func _unhandled_input(event):
	if player_nearby and not is_opened and event.is_action_pressed("interact"):
		if chest_type == ChestType.KEY and GameManager.keys <= 0:
			FeedbackManager.message_text(global_position, "需要钥匙!", Color(1, 0.3, 0.3))
			get_viewport().set_input_as_handled()
			return
		get_viewport().set_input_as_handled()
		open()

func open():
	if is_opened:
		return
	is_opened = true
	if label:
		label.visible = false

	# Consume key for key chest
	if chest_type == ChestType.KEY:
		GameManager.add_key(-1)

	# Swap to open texture with flash
	if open_texture and sprite:
		sprite.texture = open_texture
	FeedbackManager.flash_node(sprite, 0.3)

	_spawn_rewards()
	opened.emit()

func _spawn_rewards():
	match chest_type:
		ChestType.NORMAL:
			_spawn_normal_rewards()
		ChestType.EQUIPMENT:
			_spawn_equipment_rewards()
		ChestType.CURSED:
			_spawn_cursed_rewards()
		ChestType.KEY:
			_spawn_key_rewards()

func _spawn_normal_rewards():
	# Gold + small potion
	var gold = randi_range(15, 40)
	GameManager.add_gold(gold)
	FeedbackManager.gold_text(global_position + Vector2(0, -20), gold)

	# 50% chance for potion
	if randf() < 0.5:
		_spawn_item_drop({
			"type": "consumable",
			"name": "小药水",
			"heal": 25,
			"texture": AssetCatalog.potions["emerald"],
		})

func _spawn_equipment_rewards():
	# Guaranteed equipment
	var loot_manager = get_node_or_null("/root/LootManager")
	if loot_manager:
		var drops = loot_manager.roll_chest_loot("rare")
		for drop in drops:
			_spawn_item_drop(drop)
	else:
		# Fallback
		_spawn_item_drop({
			"type": "equipment",
			"name": "随机装备",
			"rarity": "rare",
			"texture": AssetCatalog.weapons["long_sword"],
		})
	FeedbackManager.message_text(global_position + Vector2(0, -40), "发现装备!", Color(0.3, 0.8, 1))

func _spawn_cursed_rewards():
	# Lose HP, gain rare item
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("take_damage"):
		player.take_damage(20, self)
	FeedbackManager.message_text(global_position + Vector2(0, -40), "诅咒生效! -20 HP", Color(0.8, 0.2, 0.8))

	# Rare equipment
	_spawn_item_drop({
		"type": "equipment",
		"name": "诅咒遗物",
		"rarity": "epic",
		"texture": AssetCatalog.curse_icons.get("i-rage", ""),
	})

func _spawn_key_rewards():
	# High value loot
	var gold = randi_range(50, 100)
	GameManager.add_gold(gold)
	FeedbackManager.gold_text(global_position + Vector2(0, -20), gold)

	# Guaranteed equipment
	var loot_manager = get_node_or_null("/root/LootManager")
	if loot_manager:
		var drops = loot_manager.roll_chest_loot("rare")
		for drop in drops:
			_spawn_item_drop(drop)

func _spawn_item_drop(data: Dictionary):
	var drop_script = load("res://scripts/items/ItemDrop.gd")
	var drop_node = Area2D.new()
	drop_node.set_script(drop_script)
	get_parent().add_child(drop_node)
	var tex = data.get("texture", "")
	drop_node.setup(data, null, global_position + Vector2(randf_range(-10, 10), -16))
