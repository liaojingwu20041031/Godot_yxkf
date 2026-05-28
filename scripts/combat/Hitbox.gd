extends Area2D

var damage: int = 10
var knockback_dir: Vector2 = Vector2.ZERO
var knockback_force: float = 150.0
var owner_node: Node = null

func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		var total_damage = _calculate_damage()
		var kb = knockback_dir * knockback_force
		area.take_damage(total_damage, kb, owner_node)
		_apply_element_effects(area)

func _on_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		var total_damage = _calculate_damage()
		body.take_damage(total_damage, owner_node)

func _calculate_damage() -> int:
	var total = damage
	# Berserker: bonus damage when low health
	if owner_node and owner_node.has_method("get") and owner_node.get("current_health") != null:
		var berserker_mult = owner_node.get_meta("berserker_multiplier", 1.0)
		if berserker_mult > 1.0:
			var hp_percent = float(owner_node.current_health) / float(owner_node.max_health)
			if hp_percent < 0.3:
				total = int(total * berserker_mult)
	return total

func _apply_element_effects(area: Area2D):
	if not owner_node:
		return
	# Fire sword: bonus fire damage
	if owner_node.get_meta("element_fire", false):
		var chance = owner_node.get_meta("element_fire_chance", 0.25)
		if randf() < chance:
			var fire_damage = 2
			if area.has_method("take_damage"):
				area.take_damage(fire_damage, Vector2.ZERO, owner_node)
			# Show fire floating text
			var ft_script = load("res://scripts/ui/FloatingText.gd")
			var ft = ft_script.new()
			ft.text = "+%d🔥" % fire_damage
			ft.color = Color(1, 0.4, 0.1, 1)
			ft.font_size = 9
			ft.global_position = area.global_position + Vector2(randf_range(-10, 10), -30)
			area.get_parent().add_child(ft)

func set_damage(value: int):
	damage = value

func set_knockback(direction: Vector2, force: float):
	knockback_dir = direction
	knockback_force = force
