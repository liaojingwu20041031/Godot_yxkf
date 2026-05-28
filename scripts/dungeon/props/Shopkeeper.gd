extends Area2D

@export var heal_cost: int = 20
@export var heal_amount: int = 50

var player_nearby: bool = false
var interaction_count: int = 0

@onready var label: Label = $ShopLabel
@onready var sprite: ColorRect = $ShopkeeperSprite

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if label:
		label.visible = false

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_nearby = true
		if label:
			label.visible = true

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_nearby = false
		if label:
			label.visible = false

func _unhandled_input(event):
	if player_nearby and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_try_trade()

func _try_trade():
	if GameManager.gold >= heal_cost:
		GameManager.add_gold(-heal_cost)
		var player = get_tree().get_first_node_in_group("player")
		if player and player.has_method("heal"):
			player.heal(heal_amount)
		interaction_count += 1
		if label:
			label.text = "治疗完成! (-%d金)" % heal_cost
		# Flash effect
		if sprite:
			var tween = create_tween()
			sprite.modulate = Color(1, 1, 2, 1)
			tween.tween_property(sprite, "modulate", Color(0.4, 0.6, 0.8, 1), 0.5)
	else:
		if label:
			label.text = "金币不足! (需要%d)" % heal_cost
	# Reset label after delay
	await get_tree().create_timer(2.0).timeout
	if label:
		label.text = "按 E 治疗 (%d金)" % heal_cost
