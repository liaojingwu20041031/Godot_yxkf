extends Node2D

var text: String = ""
var color: Color = Color.WHITE
var font_size: int = 10
var duration: float = 1.2
var rise_distance: float = 30.0

var _label: Label
var _tween: Tween

func _ready():
	_label = Label.new()
	_label.text = text
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", font_size)
	_label.add_theme_color_override("font_color", color)
	_label.position = Vector2(-40, -8)
	_label.size = Vector2(80, 16)
	add_child(_label)

	# Animate: float up and fade out
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "position:y", position.y - rise_distance, duration)
	_tween.tween_property(_label, "modulate:a", 0.0, duration).set_delay(duration * 0.4)
	_tween.chain().tween_callback(queue_free)

static func spawn(parent: Node, pos: Vector2, msg: String, col: Color = Color.WHITE, size: int = 10):
	var ft = FloatingText.new()
	ft.text = msg
	ft.color = col
	ft.font_size = size
	ft.global_position = pos
	parent.add_child(ft)
	return ft
