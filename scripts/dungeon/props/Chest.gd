extends Node2D

signal opened

@export var gold_amount: int = 30
@export var item_scene: PackedScene = null

var is_opened: bool = false
var player_nearby: bool = false

@onready var chest_area: Area2D = $ChestArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $InteractLabel

var closed_texture: Texture2D
var open_texture: Texture2D

func _ready():
	closed_texture = load("res://assets/dungeon_crawl/items/misc/chest_closed.png")
	open_texture = load("res://assets/dungeon_crawl/items/misc/chest_open.png")
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

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_nearby = false
		if label:
			label.visible = false

func _unhandled_input(event):
	if player_nearby and not is_opened and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		open()

func open():
	if is_opened:
		return
	is_opened = true
	if label:
		label.visible = false
	# Swap to open texture with flash
	if open_texture and sprite:
		sprite.texture = open_texture
	if sprite:
		var tween = create_tween()
		sprite.modulate = Color(3, 3, 1, 1)
		tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.5)
	# Spawn rewards
	_spawn_rewards()
	# Floating text: gold gained
	var ft = FloatingText.new()
	ft.text = "+%d Gold" % gold_amount
	ft.color = Color(1, 0.9, 0.3, 1)
	ft.font_size = 16
	ft.global_position = global_position + Vector2(0, -20)
	get_tree().current_scene.add_child(ft)
	# Floating text: exit opened
	var ft2 = FloatingText.new()
	ft2.text = "出口已开启"
	ft2.color = Color(0.5, 1, 0.5, 1)
	ft2.font_size = 14
	ft2.global_position = global_position + Vector2(0, -45)
	get_tree().current_scene.add_child(ft2)
	opened.emit()

func _spawn_rewards():
	if gold_amount > 0:
		GameManager.add_gold(gold_amount)
	if item_scene:
		var item = item_scene.instantiate()
		item.global_position = global_position + Vector2(0, -16)
		get_tree().current_scene.add_child(item)
