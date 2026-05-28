extends EnemyBase

var fly_height: float = 80.0
var dive_speed: float = 250.0
var is_diving: bool = false
var home_position: Vector2
var hover_time: float = 0.0

func _ready():
	max_health = 18
	attack_power = 6
	move_speed = 135.0
	detection_range = 130.0
	attack_range = 50.0
	attack_cooldown = 1.0
	monster_texture = load("res://assets/dungeon_crawl/monsters/giant_bat.png")
	home_position = global_position
	super._ready()

func _physics_process(delta):
	if is_dead:
		return
	hover_time += delta
	super._physics_process(delta)

func _idle_state(delta):
	velocity = velocity.lerp(Vector2.ZERO, 5 * delta)
	# Continuous hover bob (no fly_height offset - stay near spawn point)
	var hover = sin(hover_time * 3.0) * 10.0
	global_position.y = home_position.y + hover

func _chase_state(delta):
	if not player:
		current_state = EnemyState.IDLE
		return

	_face_player()

	if not is_diving:
		var target = player.global_position + Vector2(0, -48)
		var dir = (target - global_position).normalized()
		velocity = dir * move_speed
		# Add hover bob during chase
		velocity.y += sin(hover_time * 4.0) * 20.0

		if global_position.distance_to(player.global_position) <= attack_range:
			_start_dive()

func _start_dive():
	is_diving = true
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * dive_speed
	await get_tree().create_timer(0.4).timeout
	if attack_area:
		for body in attack_area.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(attack_power, self)
	is_diving = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _perform_attack():
	can_attack = false
	_start_dive()
