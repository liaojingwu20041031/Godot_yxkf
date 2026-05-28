extends Area2D

signal picked_up(item_data: Dictionary)

@export var item_data: Dictionary = {}
@export var bounce_height: float = 60.0
@export var bounce_duration: float = 0.5
@export var glow_color: Color = Color(1.0, 0.85, 0.2, 1.0)

var has_landed: bool = false
var is_pickable: bool = false
var _sprite: Sprite2D
var _glow: PointLight2D

func _ready():
	collision_layer = 32
	collision_mask = 1
	body_entered.connect(_on_body_entered)
	_sprite = get_node_or_null("Sprite2D")
	_glow = get_node_or_null("GlowLight")

func setup(data: Dictionary, texture: Texture2D = null, start_pos: Vector2 = Vector2.ZERO):
	item_data = _normalize_item_data(data)
	global_position = start_pos

	if not _sprite:
		_sprite = get_node_or_null("Sprite2D")
	if not _glow:
		_glow = get_node_or_null("GlowLight")

	if _sprite:
		if texture:
			_sprite.texture = texture
		else:
			var tex_path = item_data.get("texture", "")
			if tex_path != "":
				_sprite.texture = load(tex_path)

	if _glow:
		_glow.color = glow_color
		_glow.energy = 0.0
		_glow.texture_scale = 0.5

	# Start bounce after a frame to ensure everything is ready
	call_deferred("_start_bounce")

func _start_bounce():
	var start_pos = global_position
	var peak_pos = start_pos + Vector2(randf_range(-20, 20), -bounce_height)
	var land_pos = start_pos + Vector2(randf_range(-30, 30), 0)

	# Horizontal movement
	var h_tween = create_tween()
	h_tween.set_ease(Tween.EASE_OUT)
	h_tween.set_trans(Tween.TRANS_CUBIC)
	h_tween.tween_property(self, "global_position:x", land_pos.x, bounce_duration)

	# Vertical arc
	var v_tween = create_tween()
	v_tween.set_ease(Tween.EASE_OUT)
	v_tween.set_trans(Tween.TRANS_QUAD)
	v_tween.tween_property(self, "global_position:y", peak_pos.y, bounce_duration * 0.5)
	v_tween.set_ease(Tween.EASE_IN)
	v_tween.tween_property(self, "global_position:y", land_pos.y, bounce_duration * 0.5)

	# Spin during bounce
	if _sprite:
		var spin_tween = create_tween()
		spin_tween.tween_property(_sprite, "rotation", PI * 2, bounce_duration)

	await get_tree().create_timer(bounce_duration).timeout
	has_landed = true

	# Land squash effect
	if _sprite:
		var land_tween = create_tween()
		land_tween.tween_property(_sprite, "scale", Vector2(1.2, 0.7), 0.05)
		land_tween.tween_property(_sprite, "scale", Vector2(1.0, 1.0), 0.1)

	_start_glow()
	await get_tree().create_timer(0.2).timeout
	is_pickable = true

func _start_glow():
	if _glow:
		var glow_tween = create_tween()
		glow_tween.set_loops()
		glow_tween.tween_property(_glow, "energy", 0.8, 0.8)
		glow_tween.tween_property(_glow, "energy", 0.3, 0.8)

	if _sprite:
		var pulse_tween = create_tween()
		pulse_tween.set_loops()
		pulse_tween.tween_property(_sprite, "modulate", Color(1.3, 1.3, 1.0), 0.6)
		pulse_tween.tween_property(_sprite, "modulate", Color(1.0, 1.0, 1.0), 0.6)

func _on_body_entered(body: Node2D):
	if not is_pickable:
		return
	if body.is_in_group("player"):
		_pickup(body)

func _pickup(player: Node):
	is_pickable = false

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position", player.global_position + Vector2(0, -20), 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	if _sprite:
		tween.tween_property(_sprite, "scale", Vector2(0.3, 0.3), 0.1)

	await tween.finished

	_apply_item_effect(player)
	picked_up.emit(item_data)
	queue_free()

func _apply_item_effect(player: Node):
	var item_type = item_data.get("type", "")
	match item_type:
		"gold":
			var amount = item_data.get("amount", 0)
			var gold_mult = player.get_meta("gold_multiplier", 1.0)
			gold_mult += player.get_meta("equipment_gold_bonus", 0.0)
			amount = int(round(amount * gold_mult))
			GameManager.add_gold(amount)
			var ft = FloatingText.new()
			ft.global_position = global_position + Vector2(0, -20)
			ft.show_text("+%d金币" % amount, Color(1, 0.85, 0))
			get_tree().current_scene.add_child(ft)
		"key":
			GameManager.add_key(1)
			var ft = FloatingText.new()
			ft.global_position = global_position + Vector2(0, -20)
			ft.show_text("+1钥匙", Color(0.3, 0.8, 1))
			get_tree().current_scene.add_child(ft)
		"consumable":
			var heal_amount = item_data.get("heal", 0)
			if heal_amount > 0 and player.has_method("heal"):
				player.heal(heal_amount)
			var shield_amount = item_data.get("shield", 0)
			if shield_amount > 0 and player.has_method("add_shield"):
				player.add_shield(shield_amount)
		"equipment":
			_apply_equipment_effect(player)

	EventBus.item_picked_up.emit(item_data)

func _normalize_item_data(data: Dictionary) -> Dictionary:
	var normalized = data.duplicate(true)
	var nested = normalized.get("data", {})
	if nested is Dictionary:
		for key in nested:
			var current = normalized.get(key, null)
			if current == null or (current is String and current == ""):
				normalized[key] = nested[key]
	if normalized.get("type", "") == "equipment" and not normalized.has("stats"):
		normalized["stats"] = _collect_equipment_stats(normalized)
	return normalized

func _collect_equipment_stats(data: Dictionary) -> Dictionary:
	var stats = {}
	for stat in ["attack", "attack_power", "defense", "max_health", "shield", "gold_bonus", "lifesteal", "attack_speed", "speed"]:
		if data.has(stat):
			stats[stat] = data[stat]
	return stats

func _apply_equipment_effect(player: Node):
	var stats = item_data.get("stats", {})
	if not (stats is Dictionary):
		stats = _collect_equipment_stats(item_data)

	for stat in stats:
		_apply_equipment_stat(player, stat, stats[stat])

	var item_name = item_data.get("name", "装备")
	var ft = FloatingText.new()
	ft.global_position = global_position + Vector2(0, -20)
	ft.show_text("装备: %s" % item_name, Color(0.6, 0.9, 1.0))
	get_tree().current_scene.add_child(ft)

func _apply_equipment_stat(player: Node, stat: String, value):
	match stat:
		"attack", "attack_power":
			player.attack_power += int(value)
		"defense":
			player.defense += int(value)
		"max_health":
			player.max_health += int(value)
			player.current_health = min(player.current_health + int(value), player.max_health)
			EventBus.player_health_changed.emit(player.current_health, player.max_health)
		"shield":
			if player.has_method("add_shield"):
				player.add_shield(int(value))
		"gold_bonus":
			var current_gold_bonus = player.get_meta("equipment_gold_bonus", 0.0)
			player.set_meta("equipment_gold_bonus", current_gold_bonus + float(value))
		"lifesteal":
			var current_lifesteal = player.get_meta("lifesteal", 0.0)
			player.set_meta("lifesteal", current_lifesteal + float(value))
			var kill_heal = player.get_meta("on_kill_health", 0)
			player.set_meta("on_kill_health", kill_heal + max(1, int(round(float(value) * 20.0))))
		"attack_speed":
			var attack_speed_mult = player.get_meta("attack_speed_multiplier", 1.0)
			player.set_meta("attack_speed_multiplier", attack_speed_mult * (1.0 + float(value)))
		"speed":
			var speed_mult = player.get_meta("speed_multiplier", 1.0)
			player.set_meta("speed_multiplier", speed_mult * (1.0 + float(value) / 100.0))
