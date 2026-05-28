extends Node2D
class_name Interactable

signal interacted(player: Node)

@export var prompt_text: String = "按 E 交互"
@export var one_time_use: bool = true
@export var interact_cooldown: float = 0.5

var player_nearby: bool = false
var is_used: bool = false
var _cooldown_timer: float = 0.0

@onready var interact_label: Label = get_node_or_null("InteractLabel")
@onready var visual_sprite = get_node_or_null("Sprite2D")

func _ready():
	_setup_detection()
	if interact_label:
		interact_label.visible = false
		interact_label.text = prompt_text

func _setup_detection():
	var area = _find_area()
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)

func _find_area() -> Area2D:
	for child in get_children():
		if child is Area2D:
			return child
	return null

func _process(delta):
	if _cooldown_timer > 0:
		_cooldown_timer -= delta

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_nearby = true
		if can_interact():
			show_prompt()

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		player_nearby = false
		hide_prompt()

func _unhandled_input(event):
	if not player_nearby:
		return
	if _cooldown_timer > 0:
		return
	if not can_interact():
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_cooldown_timer = interact_cooldown
		var player = get_tree().get_first_node_in_group("player")
		_do_interact(player)

func can_interact() -> bool:
	if one_time_use and is_used:
		return false
	return true

func _do_interact(player: Node):
	is_used = true
	hide_prompt()
	interact(player)
	interacted.emit(player)

func interact(_player: Node):
	pass

func show_prompt():
	if interact_label:
		interact_label.visible = true
		interact_label.text = prompt_text

func hide_prompt():
	if interact_label:
		interact_label.visible = false

func flash_visual(color: Color = Color(3, 3, 1, 1), duration: float = 0.5):
	if visual_sprite:
		var tween = create_tween()
		visual_sprite.modulate = color
		tween.tween_property(visual_sprite, "modulate", Color(1, 1, 1, 1), duration)

func show_floating_text(text: String, color: Color = Color.WHITE, offset: Vector2 = Vector2(0, -20)):
	var ft = FloatingText.new()
	ft.global_position = global_position + offset
	ft.show_text(text, color)
	get_tree().current_scene.add_child(ft)
