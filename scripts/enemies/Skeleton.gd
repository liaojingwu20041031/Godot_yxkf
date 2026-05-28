extends EnemyBase

func _ready():
	max_health = 35
	attack_power = 8
	move_speed = 70.0
	detection_range = 150.0
	attack_range = 25.0
	attack_cooldown = 1.2
	monster_texture = load("res://assets/dungeon_crawl/monsters/skeletal_warrior.png")
	super._ready()

func _perform_attack():
	can_attack = false
	_face_player()
	await get_tree().create_timer(0.4).timeout
	if attack_area:
		for body in attack_area.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(attack_power, self)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	current_state = EnemyState.CHASE
