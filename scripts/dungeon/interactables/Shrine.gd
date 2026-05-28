extends Interactable

@export var sacrifice_hp_cost: int = 20
@export var key_cost: int = 50

var _choice_panel: CanvasLayer
var _is_showing_choices: bool = false

func _ready():
	prompt_text = "按 E 与祭坛交互"
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
	panel.offset_top = -100
	panel.offset_right = 120
	panel.offset_bottom = 100
	_choice_panel.add_child(panel)

	var title = Label.new()
	title.text = "祭坛"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.9, 0.7, 1.0))
	panel.add_child(title)

	var sep = HSeparator.new()
	panel.add_child(sep)

	# Option 1: Sacrifice HP for random upgrade
	var hp_text = "献祭 %d 生命 → 随机强化" % sacrifice_hp_cost
	var btn1 = _create_choice_button(hp_text, Color(1, 0.4, 0.4))
	btn1.pressed.connect(func(): _on_sacrifice_hp(player))
	panel.add_child(btn1)

	# Option 2: Spend gold for key
	var gold_text = "花费 %d 金币 → 钥匙" % key_cost
	var btn2 = _create_choice_button(gold_text, Color(1, 0.85, 0.2))
	btn2.pressed.connect(func(): _on_buy_key(player))
	panel.add_child(btn2)

	# Option 3: Accept curse for rare equipment
	var btn3 = _create_choice_button("接受诅咒 → 稀有装备", Color(0.8, 0.3, 1.0))
	btn3.pressed.connect(func(): _on_accept_curse(player))
	panel.add_child(btn3)

	# Option 4: Leave
	var btn4 = _create_choice_button("离开", Color(0.6, 0.6, 0.6))
	btn4.pressed.connect(func(): _on_leave())
	panel.add_child(btn4)

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

func _on_sacrifice_hp(player: Node):
	_close_choices()
	if player.has_method("take_damage"):
		player.take_damage(sacrifice_hp_cost, self)
		show_floating_text("-%d HP" % sacrifice_hp_cost, Color(1, 0.3, 0.3))

	# Give random upgrade
	var upgrade_manager = get_node_or_null("/root/UpgradeManager")
	if upgrade_manager:
		var upgrades = upgrade_manager.get_random_upgrades(1)
		if upgrades.size() > 0:
			upgrade_manager.apply_upgrade(player, upgrades[0]["id"])
			show_floating_text("获得: %s" % upgrades[0].get("name", "强化"), Color(0.9, 0.7, 1.0))

	flash_visual(Color(2, 0.5, 0.5, 1), 0.8)

func _on_buy_key(player: Node):
	_close_choices()
	if GameManager.gold >= key_cost:
		GameManager.add_gold(-key_cost)
		GameManager.add_key(1)
		show_floating_text("+1 钥匙", Color(0.3, 0.8, 1.0))
		flash_visual(Color(1, 0.85, 0.2, 1), 0.5)
	else:
		show_floating_text("金币不足!", Color(1, 0.3, 0.3))

func _on_accept_curse(player: Node):
	_close_choices()
	# Give rare equipment via item pickup
	var item_data = {
		"type": "equipment",
		"name": "诅咒遗物",
		"description": "来自祭坛的神秘力量",
		"rarity": "rare",
		"texture": AssetCatalog.blessing_icons.get("i-rage", ""),
	}
	EventBus.item_picked_up.emit(item_data)
	show_floating_text("获得诅咒遗物", Color(0.8, 0.3, 1.0))
	flash_visual(Color(0.8, 0.3, 1.0, 1), 0.8)

func _on_leave():
	_close_choices()

func _close_choices():
	if _choice_panel:
		_choice_panel.queue_free()
		_choice_panel = null
	_is_showing_choices = false
	get_tree().paused = false
