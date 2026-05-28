extends CanvasLayer

const COLOR_HEALTH = Color(0.80, 0.15, 0.10, 1.0)
const COLOR_HEALTH_BG = Color(0.25, 0.08, 0.05, 1.0)
const COLOR_SHIELD = Color(0.30, 0.50, 0.80, 1.0)
const COLOR_BORDER = Color(0.45, 0.35, 0.20, 1.0)
const COLOR_GOLD = Color(0.90, 0.75, 0.20, 1.0)
const COLOR_TEXT = Color(0.95, 0.90, 0.75, 1.0)
const COLOR_BOSS = Color(0.70, 0.10, 0.30, 1.0)

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/HealthLabel
@onready var shield_bar: ProgressBar = $ShieldBar
@onready var gold_label: Label = $GoldLabel
@onready var key_label: Label = $KeyLabel
@onready var room_label: Label = $RoomLabel
@onready var boss_bar: ProgressBar = $BossBar

func _ready():
	EventBus.player_health_changed.connect(_on_health_changed)
	EventBus.player_shield_changed.connect(_on_shield_changed)
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.key_changed.connect(_on_key_changed)
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.show_room_message.connect(_on_room_message)
	_apply_theme()
	_update_all()

func _apply_theme():
	_style_bar(health_bar, COLOR_HEALTH)
	_style_bar(shield_bar, COLOR_SHIELD)
	if boss_bar:
		_style_bar(boss_bar, COLOR_BOSS)
	if gold_label:
		gold_label.add_theme_color_override("font_color", COLOR_GOLD)
	if key_label:
		key_label.add_theme_color_override("font_color", COLOR_GOLD)
	if room_label:
		room_label.add_theme_color_override("font_color", COLOR_TEXT)
	if health_label:
		health_label.add_theme_color_override("font_color", COLOR_TEXT)

func _style_bar(bar: ProgressBar, fill_color: Color):
	if bar == null:
		return
	var fill = StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("fill", fill)
	var bg = StyleBoxFlat.new()
	bg.bg_color = COLOR_HEALTH_BG
	bg.border_color = COLOR_BORDER
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("background", bg)

func _update_all():
	if health_bar:
		health_bar.value = 100
	if health_label:
		health_label.text = "100/100"
	if shield_bar:
		shield_bar.value = 0
	if gold_label:
		gold_label.text = "Gold: 0"
	if key_label:
		key_label.text = "Keys: 0"

func _on_health_changed(current: int, maximum: int):
	if health_bar:
		health_bar.max_value = maximum
		health_bar.value = current
	if health_label:
		health_label.text = "%d/%d" % [current, maximum]

func _on_shield_changed(current: int, maximum: int):
	if shield_bar:
		shield_bar.max_value = maximum
		shield_bar.value = current

func _on_gold_changed(amount: int):
	if gold_label:
		gold_label.text = "Gold: %d" % amount

func _on_key_changed(amount: int):
	if key_label:
		key_label.text = "Keys: %d" % amount

func _on_room_entered(room_type: String):
	if room_label:
		var objectives = {
			"START": "→ 走到出口",
			"COMBAT": "击败所有敌人",
			"ELITE": "击败所有敌人",
			"TREASURE": "打开宝箱",
			"SHOP": "与商人交易",
			"REST": "休息恢复",
			"BOSS": "击败 Boss",
		}
		room_label.text = objectives.get(room_type, room_type)

func _on_room_message(text: String):
	if room_label:
		room_label.text = text
		# Auto-clear after 3 seconds
		await get_tree().create_timer(3.0).timeout
		if room_label and room_label.text == text:
			room_label.text = ""

func show_boss_bar(boss_name: String, health: int):
	if boss_bar:
		boss_bar.visible = true
		boss_bar.max_value = health
		boss_bar.value = health

func update_boss_health(health: int):
	if boss_bar:
		boss_bar.value = health

func hide_boss_bar():
	if boss_bar:
		boss_bar.visible = false
