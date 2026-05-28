extends Control

const COLOR_BORDER_LIGHT = Color(0.65, 0.50, 0.30, 1.0)
const COLOR_TEXT = Color(0.95, 0.90, 0.75, 1.0)
const COLOR_GOLD = Color(0.90, 0.75, 0.20, 1.0)
const COLOR_BUTTON_NORMAL = Color(0.20, 0.15, 0.10, 1.0)
const COLOR_BUTTON_HOVER = Color(0.30, 0.22, 0.15, 1.0)

func _ready():
	_apply_theme()

func _apply_theme():
	var bg = $VBox
	if bg:
		var panel = StyleBoxFlat.new()
		panel.bg_color = Color(0.05, 0.10, 0.18, 0.95)
		panel.border_color = COLOR_BORDER_LIGHT
		panel.set_border_width_all(3)
		panel.set_corner_radius_all(8)
		panel.set_content_margin_all(20)
		bg.add_theme_stylebox_override("panel", panel)

	var btn = $VBox.get_node_or_null("MenuButton")
	if btn:
		var normal = StyleBoxFlat.new()
		normal.bg_color = COLOR_BUTTON_NORMAL
		normal.border_color = COLOR_BORDER_LIGHT
		normal.set_border_width_all(2)
		normal.set_corner_radius_all(4)
		normal.set_content_margin_all(8)
		btn.add_theme_stylebox_override("normal", normal)

		var hover = StyleBoxFlat.new()
		hover.bg_color = COLOR_BUTTON_HOVER
		hover.border_color = COLOR_GOLD
		hover.set_border_width_all(2)
		hover.set_corner_radius_all(4)
		hover.set_content_margin_all(8)
		btn.add_theme_stylebox_override("hover", hover)

		btn.add_theme_color_override("font_color", COLOR_TEXT)

func _on_menu_pressed():
	GameManager.go_to_main_menu()
