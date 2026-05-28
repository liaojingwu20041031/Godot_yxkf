extends StaticBody2D

@export var is_open: bool = false

@onready var collision: CollisionShape2D = $CollisionShape2D
var sprite_node: Node

var closed_texture: Texture2D
var open_texture: Texture2D
var tween: Tween

func _ready():
	sprite_node = get_node_or_null("Sprite2D")
	closed_texture = load("res://assets/dungeon_crawl/doors/dngn_closed_door.png")
	open_texture = load("res://assets/dungeon_crawl/doors/dngn_open_door.png")
	_update_visual()

func open():
	is_open = true
	_update_visual()
	if sprite_node and tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(sprite_node, "modulate:a", 0.5, 0.3)

func close():
	is_open = false
	_update_visual()
	if sprite_node and tween and tween.is_valid():
		tween.kill()
	tween = create_tween()
	tween.tween_property(sprite_node, "modulate:a", 1.0, 0.2)

func _update_visual():
	if collision:
		collision.disabled = is_open
	if sprite_node == null:
		return
	if is_open:
		if open_texture and sprite_node is Sprite2D:
			sprite_node.texture = open_texture
		sprite_node.modulate = Color(1, 1, 1, 0.5)
	else:
		if closed_texture and sprite_node is Sprite2D:
			sprite_node.texture = closed_texture
		sprite_node.modulate = Color(1, 1, 1, 1.0)
