extends Area2D

@export var heal_amount: int = 30

var player_nearby: bool = false
var used: bool = false

@onready var label: Label = $FireLabel
@onready var sprite: ColorRect = $FireSprite

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if label:
		label.visible = false

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_nearby = true
		if not used and label:
			label.visible = true

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_nearby = false
		if label:
			label.visible = false

func _unhandled_input(event):
	if player_nearby and not used and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_heal_player()

func _heal_player():
	used = true
	if label:
		label.text = "已恢复"
	# Heal the player
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("heal"):
		player.heal(heal_amount)
	# Visual feedback - bright flash
	if sprite:
		var tween = create_tween()
		sprite.modulate = Color(3, 2, 1, 1)
		tween.tween_property(sprite, "modulate", Color(1, 0.5, 0.2, 1), 0.8)
	# Hide label after a moment
	await get_tree().create_timer(2.0).timeout
	if label:
		label.visible = false
