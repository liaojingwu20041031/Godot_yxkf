extends Interactable

@export var heal_percent: float = 0.5

var _choice_panel: CanvasLayer
var _is_showing_choices: bool = false

func _ready():
	prompt_text = "按 E 休息"
	one_time_use = false
	super._ready()

func interact(player: Node):
	_show_choices(player)

func _show_choices(player: Node):
	if _is_showing_choices:
		return
	_is_showing_choices = true

	_choice_panel = CanvasLayer.new()
	_choice_panel.layer = 10
	add_child(_choice_panel)

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_choice_panel.add_child(bg)

	var panel = VBoxContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -120
	panel.offset_top = -80
	panel.offset_right = 120
	panel.offset_bottom = 80
	_choice_panel.add_child(panel)

	var title = Label.new()
	title.text = "篝火休息"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1, 0.7, 0.3))
	panel.add_child(title)

	var sep = HSeparator.new()
	panel.add_child(sep)

	# Option 1: Heal 50% HP
	var btn1 = _create_choice_button("回复 50%% 生命", Color(0.3, 1, 0.3))
	btn1.pressed.connect(func(): _on_heal(player))
	panel.add_child(btn1)

	# Option 2: Upgrade random existing upgrade
	var btn2 = _create_choice_button("强化已有能力", Color(0.9, 0.7, 1.0))
	btn2.pressed.connect(func(): _on_upgrade(player))
	panel.add_child(btn2)

	# Option 3: Get a key
	var btn3 = _create_choice_button("获得 1 把钥匙", Color(0.3, 0.8, 1.0))
	btn3.pressed.connect(func(): _on_get_key())
	panel.add_child(btn3)

	get_tree().paused = true

func _create_choice_button(text: String, color: Color) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 12)

	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.15, 0.10, 0.08, 0.9)
	normal.border_color = color
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(4)
	normal.set_content_margin_all(6)
	btn.add_theme_stylebox_override("normal", normal)

	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(0.25, 0.18, 0.12, 1.0)
	hover.border_color = color
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(4)
	hover.set_content_margin_all(6)
	btn.add_theme_stylebox_override("hover", hover)

	btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.75))
	btn.add_theme_color_override("font_hover_color", color)

	return btn

func _on_heal(player: Node):
	_close_choices()
	if player.has_method("heal"):
		var max_hp = player.get("max_health") if player.has_method("get") else 100
		var heal_amount = int(max_hp * heal_percent)
		player.heal(heal_amount)
		show_floating_text("+%d HP" % heal_amount, Color(0.3, 1, 0.3))
	flash_visual(Color(1, 0.8, 0.3, 1), 0.5)

func _on_upgrade(player: Node):
	_close_choices()
	var upgrade_manager = get_node_or_null("/root/UpgradeManager")
	if upgrade_manager:
		var upgrades = upgrade_manager.get_random_upgrades(1)
		if upgrades.size() > 0:
			upgrade_manager.apply_upgrade(player, upgrades[0]["id"])
			show_floating_text("强化: %s" % upgrades[0].get("name", ""), Color(0.9, 0.7, 1.0))
		else:
			show_floating_text("没有可强化的能力", Color(0.6, 0.6, 0.6))
	flash_visual(Color(0.9, 0.7, 1.0, 1), 0.5)

func _on_get_key():
	_close_choices()
	GameManager.add_key(1)
	show_floating_text("+1 钥匙", Color(0.3, 0.8, 1.0))
	flash_visual(Color(0.3, 0.8, 1.0, 1), 0.5)

func _close_choices():
	if _choice_panel:
		_choice_panel.queue_free()
		_choice_panel = null
	_is_showing_choices = false
	get_tree().paused = false
