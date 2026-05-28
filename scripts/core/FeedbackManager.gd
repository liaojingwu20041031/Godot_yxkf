extends Node

# Hit stop - briefly slow time on impact
func hit_stop(duration: float = 0.04):
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

# Screen shake via camera offset
var _shake_strength: float = 0.0
var _shake_timer: float = 0.0
var _camera: Camera2D

func setup(camera: Camera2D):
	_camera = camera

func screen_shake(strength: float = 4.0, duration: float = 0.15):
	_shake_strength = strength
	_shake_timer = duration

func _process(delta):
	if _shake_timer > 0:
		_shake_timer -= delta
		if _camera:
			_camera.offset = Vector2(
				randf_range(-_shake_strength, _shake_strength),
				randf_range(-_shake_strength, _shake_strength)
			)
	else:
		if _camera:
			_camera.offset = Vector2.ZERO

# Flash a node white briefly
func flash_node(node: Node, duration: float = 0.1):
	if not node:
		return
	var original_modulate = node.modulate
	node.modulate = Color(5, 5, 5, 1)
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(node):
		node.modulate = original_modulate

# Spawn floating text at world position
func floating_text(pos: Vector2, text: String, color: Color = Color.WHITE, size: int = 14):
	var ft = FloatingText.new()
	ft.global_position = pos
	ft.show_text(text, color, size)
	get_tree().current_scene.add_child(ft)

# Floating text for damage
func damage_text(pos: Vector2, amount: int):
	floating_text(pos + Vector2(randf_range(-10, 10), -10), str(amount), Color(1, 0.3, 0.3))

# Floating text for healing
func heal_text(pos: Vector2, amount: int):
	floating_text(pos + Vector2(0, -10), "+%d HP" % amount, Color(0.3, 1, 0.3))

# Floating text for gold
func gold_text(pos: Vector2, amount: int):
	floating_text(pos + Vector2(0, -10), "+%d金币" % amount, Color(1, 0.85, 0))

# Floating text for key
func key_text(pos: Vector2):
	floating_text(pos + Vector2(0, -10), "+1钥匙", Color(0.3, 0.8, 1))

# Floating text for message
func message_text(pos: Vector2, text: String, color: Color = Color(0.7, 0.7, 0.7)):
	floating_text(pos + Vector2(0, -20), text, color, 12)
