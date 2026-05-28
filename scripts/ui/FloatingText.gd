class_name FloatingText
extends Node2D

var text: String = ""
var color: Color = Color.WHITE
var font_size: int = 14
var duration: float = 1.5
var rise_distance: float = 40.0

var _label: Label
var _shadow: Label
var _tween: Tween

func _ready():
	# Shadow label for readability
	_shadow = Label.new()
	_shadow.text = text
	_shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_shadow.add_theme_font_size_override("font_size", font_size)
	_shadow.add_theme_color_override("font_color", Color(0, 0, 0, 0.8))
	_shadow.position = Vector2(-41, -7)
	_shadow.size = Vector2(82, 18)
	add_child(_shadow)

	# Main label
	_label = Label.new()
	_label.text = text
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", color)
	_label.position = Vector2(-40, -8)
	_label.size = Vector2(80, 18)
	add_child(_label)

	# Animate: float up and fade out
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "position:y", position.y - rise_distance, duration)
	_tween.tween_property(_label, "modulate:a", 0.0, duration).set_delay(duration * 0.5)
	_tween.tween_property(_shadow, "modulate:a", 0.0, duration).set_delay(duration * 0.5)
	_tween.chain().tween_callback(queue_free)

func show_text(msg: String, col: Color = Color.WHITE, size: int = 14):
	text = msg
	color = col
	font_size = size

static func spawn(parent: Node, pos: Vector2, msg: String, col: Color = Color.WHITE, size: int = 14):
	var ft = FloatingText.new()
	ft.text = msg
	ft.color = col
	ft.font_size = size
	ft.global_position = pos
	parent.add_child(ft)
	return ft
