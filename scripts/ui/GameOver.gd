extends Control

const COLOR_BG_DARK = Color(0.08, 0.06, 0.12, 0.95)
const COLOR_BORDER = Color(0.45, 0.35, 0.20, 1.0)
const COLOR_BORDER_LIGHT = Color(0.65, 0.50, 0.30, 1.0)
const COLOR_TEXT = Color(0.95, 0.90, 0.75, 1.0)
const COLOR_BUTTON_NORMAL = Color(0.20, 0.15, 0.10, 1.0)
const COLOR_BUTTON_HOVER = Color(0.30, 0.22, 0.15, 1.0)

func _ready():
	_apply_theme()
	$VBox/RetryButton.grab_focus()

func _apply_theme():
	var bg = $VBox
	if bg:
		var panel = StyleBoxFlat.new()
		panel.bg_color = COLOR_BG_DARK
		panel.border_color = COLOR_BORDER
		panel.set_border_width_all(3)
		panel.set_corner_radius_all(8)
		panel.set_content_margin_all(20)
		bg.add_theme_stylebox_override("panel", panel)

	for btn_name in ["RetryButton", "MenuButton"]:
		var btn = $VBox.get_node_or_null(btn_name)
		if btn:
			var normal = StyleBoxFlat.new()
			normal.bg_color = COLOR_BUTTON_NORMAL
			normal.border_color = COLOR_BORDER
			normal.set_border_width_all(2)
			normal.set_corner_radius_all(4)
			normal.set_content_margin_all(8)
			btn.add_theme_stylebox_override("normal", normal)

			var hover = StyleBoxFlat.new()
			hover.bg_color = COLOR_BUTTON_HOVER
			hover.border_color = COLOR_BORDER_LIGHT
			hover.set_border_width_all(2)
			hover.set_corner_radius_all(4)
			hover.set_content_margin_all(8)
			btn.add_theme_stylebox_override("hover", hover)

			btn.add_theme_color_override("font_color", COLOR_TEXT)

func _on_retry_pressed():
	GameManager.restart_game()

func _on_menu_pressed():
	GameManager.go_to_main_menu()
