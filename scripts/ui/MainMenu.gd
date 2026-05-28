extends Control

const C_BG = Color(0.08, 0.06, 0.12, 0.95)
const C_PANEL = Color(0.15, 0.10, 0.08, 0.9)
const C_BORDER = Color(0.45, 0.35, 0.20, 1.0)
const C_BORDER_L = Color(0.65, 0.50, 0.30, 1.0)
const C_TEXT = Color(0.95, 0.90, 0.75, 1.0)
const C_DIM = Color(0.60, 0.55, 0.45, 1.0)
const C_GOLD = Color(0.90, 0.75, 0.20, 1.0)
const C_BTN = Color(0.20, 0.15, 0.10, 1.0)
const C_BTN_H = Color(0.30, 0.22, 0.15, 1.0)
const C_BTN_P = Color(0.12, 0.08, 0.05, 1.0)

func _ready():
	var bg = ColorRect.new()
	bg.color = C_BG
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var center = CenterContainer.new()
	center.set_anchors_preset(PRESET_FULL_RECT)
	add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(280, 300)
	var ps = StyleBoxFlat.new()
	ps.bg_color = C_PANEL
	ps.border_color = C_BORDER
	ps.set_border_width_all(3)
	ps.set_corner_radius_all(8)
	ps.set_content_margin_all(20)
	panel.add_theme_stylebox_override("panel", ps)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(240, 260)
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = "灰烬骑士：地牢回廊"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", C_GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sub = Label.new()
	sub.text = "Ash Knight: Dungeon Corridor"
	sub.add_theme_font_size_override("font_size", 10)
	sub.add_theme_color_override("font_color", C_DIM)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sub)

	var sp = Control.new()
	sp.custom_minimum_size = Vector2(0, 15)
	vbox.add_child(sp)

	var btn1 = _mkbtn("开始游戏")
	btn1.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/rooms/TestRoom.tscn"))
	vbox.add_child(btn1)

	var btn2 = _mkbtn("设置")
	vbox.add_child(btn2)

	var btn3 = _mkbtn("退出游戏")
	btn3.pressed.connect(func(): get_tree().quit())
	vbox.add_child(btn3)

	var ver = Label.new()
	ver.text = "MVP v0.2"
	ver.add_theme_font_size_override("font_size", 9)
	ver.add_theme_color_override("font_color", C_DIM)
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ver.set_anchors_preset(PRESET_BOTTOM_RIGHT)
	ver.offset_left = -80
	ver.offset_top = -20
	add_child(ver)

func _mkbtn(text: String) -> Button:
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(200, 32)
	var n = StyleBoxFlat.new()
	n.bg_color = C_BTN
	n.border_color = C_BORDER
	n.set_border_width_all(2)
	n.set_corner_radius_all(4)
	n.set_content_margin_all(6)
	b.add_theme_stylebox_override("normal", n)
	var h = StyleBoxFlat.new()
	h.bg_color = C_BTN_H
	h.border_color = C_BORDER_L
	h.set_border_width_all(2)
	h.set_corner_radius_all(4)
	h.set_content_margin_all(6)
	b.add_theme_stylebox_override("hover", h)
	var p = StyleBoxFlat.new()
	p.bg_color = C_BTN_P
	p.border_color = C_BORDER
	p.set_border_width_all(2)
	p.set_corner_radius_all(4)
	p.set_content_margin_all(6)
	b.add_theme_stylebox_override("pressed", p)
	b.add_theme_color_override("font_color", C_TEXT)
	b.add_theme_color_override("font_hover_color", C_GOLD)
	return b
