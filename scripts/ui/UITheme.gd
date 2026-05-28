extends Node

# Medieval pixel art color palette
const COLOR_BG_DARK = Color(0.08, 0.06, 0.12, 0.95)
const COLOR_BG_PANEL = Color(0.15, 0.10, 0.08, 0.9)
const COLOR_BORDER = Color(0.45, 0.35, 0.20, 1.0)
const COLOR_BORDER_LIGHT = Color(0.65, 0.50, 0.30, 1.0)
const COLOR_TEXT = Color(0.95, 0.90, 0.75, 1.0)
const COLOR_TEXT_DIM = Color(0.60, 0.55, 0.45, 1.0)
const COLOR_HEALTH = Color(0.80, 0.15, 0.10, 1.0)
const COLOR_HEALTH_BG = Color(0.25, 0.08, 0.05, 1.0)
const COLOR_SHIELD = Color(0.30, 0.50, 0.80, 1.0)
const COLOR_MANA = Color(0.20, 0.30, 0.80, 1.0)
const COLOR_XP = Color(0.20, 0.70, 0.30, 1.0)
const COLOR_GOLD = Color(0.90, 0.75, 0.20, 1.0)
const COLOR_BUTTON_NORMAL = Color(0.20, 0.15, 0.10, 1.0)
const COLOR_BUTTON_HOVER = Color(0.30, 0.22, 0.15, 1.0)
const COLOR_BUTTON_PRESSED = Color(0.12, 0.08, 0.05, 1.0)
const COLOR_BOSS = Color(0.70, 0.10, 0.30, 1.0)

static func create_game_theme() -> Theme:
	var theme = Theme.new()
	theme.set_default_font_size(12)

	# Panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = COLOR_BG_PANEL
	panel_style.border_color = COLOR_BORDER
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(3)
	panel_style.set_content_margin_all(8)
	theme.set_stylebox("panel", "Panel", panel_style)

	# Button normal
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = COLOR_BUTTON_NORMAL
	btn_normal.border_color = COLOR_BORDER
	btn_normal.set_border_width_all(2)
	btn_normal.set_corner_radius_all(3)
	btn_normal.set_content_margin_all(6)
	theme.set_stylebox("normal", "Button", btn_normal)

	# Button hover
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = COLOR_BUTTON_HOVER
	btn_hover.border_color = COLOR_BORDER_LIGHT
	btn_hover.set_border_width_all(2)
	btn_hover.set_corner_radius_all(3)
	btn_hover.set_content_margin_all(6)
	theme.set_stylebox("hover", "Button", btn_hover)

	# Button pressed
	var btn_pressed = StyleBoxFlat.new()
	btn_pressed.bg_color = COLOR_BUTTON_PRESSED
	btn_pressed.border_color = COLOR_BORDER
	btn_pressed.set_border_width_all(2)
	btn_pressed.set_corner_radius_all(3)
	btn_pressed.set_content_margin_all(6)
	theme.set_stylebox("pressed", "Button", btn_pressed)

	# Button focus
	var btn_focus = StyleBoxFlat.new()
	btn_focus.bg_color = COLOR_BUTTON_HOVER
	btn_focus.border_color = COLOR_GOLD
	btn_focus.set_border_width_all(2)
	btn_focus.set_corner_radius_all(3)
	btn_focus.set_content_margin_all(6)
	theme.set_stylebox("focus", "Button", btn_focus)

	theme.set_color("font_color", "Button", COLOR_TEXT)
	theme.set_color("font_hover_color", "Button", COLOR_GOLD)
	theme.set_color("font_pressed_color", "Button", COLOR_TEXT_DIM)

	# Label
	theme.set_color("font_color", "Label", COLOR_TEXT)

	# ProgressBar
	var bar_bg = StyleBoxFlat.new()
	bar_bg.bg_color = COLOR_HEALTH_BG
	bar_bg.border_color = COLOR_BORDER
	bar_bg.set_border_width_all(1)
	bar_bg.set_corner_radius_all(2)
	theme.set_stylebox("background", "ProgressBar", bar_bg)

	var bar_fill = StyleBoxFlat.new()
	bar_fill.bg_color = COLOR_HEALTH
	bar_fill.set_corner_radius_all(2)
	theme.set_stylebox("fill", "ProgressBar", bar_fill)

	# CheckBox
	theme.set_color("font_color", "CheckBox", COLOR_TEXT)

	# LineEdit
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = COLOR_BG_DARK
	input_style.border_color = COLOR_BORDER
	input_style.set_border_width_all(1)
	input_style.set_content_margin_all(4)
	theme.set_stylebox("normal", "LineEdit", input_style)

	return theme

static func style_health_bar(bar: ProgressBar, is_boss: bool = false) -> void:
	if bar == null:
		return
	var fill = StyleBoxFlat.new()
	fill.bg_color = COLOR_BOSS if is_boss else COLOR_HEALTH
	fill.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("fill", fill)
	var bg = StyleBoxFlat.new()
	bg.bg_color = COLOR_HEALTH_BG
	bg.border_color = COLOR_BORDER
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("background", bg)

static func style_shield_bar(bar: ProgressBar) -> void:
	if bar == null:
		return
	var fill = StyleBoxFlat.new()
	fill.bg_color = COLOR_SHIELD
	fill.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("fill", fill)

static func style_gold_label(label: Label) -> void:
	if label == null:
		return
	label.add_theme_color_override("font_color", COLOR_GOLD)

static func apply_theme_to_scene(root: Node) -> void:
	var theme = create_game_theme()
	_apply_theme_recursive(root, theme)

static func _apply_theme_recursive(node: Node, theme: Theme) -> void:
	if node is Control:
		node.theme = theme
	for child in node.get_children():
		_apply_theme_recursive(child, theme)
