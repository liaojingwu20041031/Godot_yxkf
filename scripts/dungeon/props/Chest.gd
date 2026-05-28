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
	# Swap to open texture
	if open_texture and sprite:
		sprite.texture = open_texture
	# Flash effect
	if sprite:
		var tween = create_tween()
		sprite.modulate = Color(3, 3, 1, 1)
		tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.5)
	# Spawn rewards with visual feedback
	_spawn_rewards()
	# Show floating text
	_show_floating_text("+%d Gold" % gold_amount)
	# Show exit opened message
	_show_floating_text("出口已开启", Vector2(0, -40))
	opened.emit()

func _spawn_rewards():
	# Gold reward
	if gold_amount > 0:
		GameManager.add_gold(gold_amount)
	# Item reward
	if item_scene:
		var item = item_scene.instantiate()
		item.global_position = global_position + Vector2(0, -16)
		get_tree().current_scene.add_child(item)

func _show_floating_text(text: String, offset: Vector2 = Vector2(0, -20)):
	var floating_label = Label.new()
	floating_label.text = text
	floating_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	floating_label.add_theme_font_size_override("font_size", 10)
	floating_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3, 1))
	floating_label.position = global_position + offset + Vector2(-40, 0)
	floating_label.size = Vector2(80, 16)
	get_tree().current_scene.add_child(floating_label)
	# Animate: float up and fade out
	var tween = floating_label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(floating_label, "position:y", floating_label.position.y - 30, 1.5)
	tween.tween_property(floating_label, "modulate:a", 0.0, 1.5).set_delay(0.5)
	tween.chain().tween_callback(floating_label.queue_free)
