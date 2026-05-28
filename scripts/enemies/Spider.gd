extends EnemyBase

var poison_damage: int = 1
var poison_duration: float = 5.0
var lunge_speed: float = 200.0
var is_lunging: bool = false

func _ready():
	max_health = 22
	attack_power = 5
	move_speed = 115.0
	detection_range = 120.0
	attack_range = 20.0
	attack_cooldown = 0.8
	monster_texture = load("res://assets/dungeon_crawl/monsters/jumping_spider.png")
	super._ready()

func _chase_state(delta):
	if not player:
		current_state = EnemyState.IDLE
		return

	_face_player()
	var dir = (player.global_position - global_position).normalized()
	velocity.x = dir.x * move_speed

	if global_position.distance_to(player.global_position) <= attack_range:
		current_state = EnemyState.ATTACK

func _perform_attack():
	can_attack = false
	_face_player()
	# Lunge attack
	is_lunging = true
	var dir = 1 if facing_right else -1
	velocity.x = lunge_speed * dir
	velocity.y = -80
	await get_tree().create_timer(0.25).timeout
	is_lunging = false
	if attack_area:
		for body in attack_area.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(attack_power, self)
				_apply_poison(body)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	current_state = EnemyState.CHASE

func _apply_poison(target: Node):
	if target.has_method("add_status_effect"):
		target.add_status_effect("poison", poison_damage, poison_duration)
	elif target.has_method("take_damage"):
		for i in range(int(poison_duration)):
			await get_tree().create_timer(1.0).timeout
			if is_instance_valid(target) and not is_dead:
				target.take_damage(poison_damage, self)
