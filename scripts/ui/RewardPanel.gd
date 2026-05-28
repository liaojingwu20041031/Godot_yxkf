extends Control

signal reward_selected(reward_id: String)

const COLOR_BG_PANEL = Color(0.15, 0.10, 0.08, 0.9)
const COLOR_BORDER = Color(0.45, 0.35, 0.20, 1.0)
const COLOR_GOLD = Color(0.90, 0.75, 0.20, 1.0)
const COLOR_TEXT = Color(0.95, 0.90, 0.75, 1.0)
const COLOR_TEXT_DIM = Color(0.60, 0.55, 0.45, 1.0)
const COLOR_BUTTON_HOVER = Color(0.30, 0.22, 0.15, 1.0)
const COLOR_BUTTON_PRESSED = Color(0.12, 0.08, 0.05, 1.0)
const COLOR_BORDER_LIGHT = Color(0.65, 0.50, 0.30, 1.0)

var rewards: Array = []

@onready var card1: Button = $VBox/CardContainer/Card1
@onready var card2: Button = $VBox/CardContainer/Card2
@onready var card3: Button = $VBox/CardContainer/Card3

func _ready():
	visible = false
	EventBus.show_reward_panel.connect(_on_show_reward)
	card1.pressed.connect(func(): _select_reward(0))
	card2.pressed.connect(func(): _select_reward(1))
	card3.pressed.connect(func(): _select_reward(2))
	_apply_theme()

func _apply_theme():
	var cards = [card1, card2, card3]
	for card in cards:
		if card:
			_style_card(card)

func _style_card(card: Button):
	var normal = StyleBoxFlat.new()
	normal.bg_color = COLOR_BG_PANEL
	normal.border_color = COLOR_BORDER
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(6)
	normal.set_content_margin_all(10)
	card.add_theme_stylebox_override("normal", normal)

	var hover = StyleBoxFlat.new()
	hover.bg_color = COLOR_BUTTON_HOVER
	hover.border_color = COLOR_GOLD
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(6)
	hover.set_content_margin_all(10)
	card.add_theme_stylebox_override("hover", hover)

	var pressed = StyleBoxFlat.new()
	pressed.bg_color = COLOR_BUTTON_PRESSED
	pressed.border_color = COLOR_BORDER_LIGHT
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(6)
	pressed.set_content_margin_all(10)
	card.add_theme_stylebox_override("pressed", pressed)

	card.add_theme_color_override("font_color", COLOR_TEXT)
	card.add_theme_color_override("font_hover_color", COLOR_GOLD)

func _on_show_reward(reward_data: Array):
	rewards = reward_data
	_update_cards()
	visible = true
	get_tree().paused = true

func _update_cards():
	var cards = [card1, card2, card3]
	for i in range(min(rewards.size(), cards.size())):
		var reward = rewards[i]
		var label = cards[i].get_node("Label")
		var desc = cards[i].get_node("Description")
		if label:
			label.text = reward.get("name", "Unknown")
			label.add_theme_color_override("font_color", COLOR_GOLD)
		if desc:
			desc.text = reward.get("description", "")
			desc.add_theme_color_override("font_color", COLOR_TEXT_DIM)

func _select_reward(index: int):
	if index < rewards.size():
		var reward = rewards[index]
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var upgrade_manager = get_node_or_null("/root/UpgradeManager")
			if upgrade_manager:
				upgrade_manager.apply_upgrade(player, reward["id"])
	visible = false
	get_tree().paused = false
	EventBus.hide_reward_panel.emit()
