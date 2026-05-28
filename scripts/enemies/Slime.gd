extends EnemyBase

@export var split_count: int = 1
@export var slow_amount: float = 0.5

var _is_split: bool = false

func _ready():
	max_health = 30
	attack_power = 4
	move_speed = 40.0
	detection_range = 100.0
	attack_range = 18.0
	attack_cooldown = 1.2
	monster_texture = load("res://assets/dungeon_crawl/monsters/orc_warrior.png")
	super._ready()

func _chase_state(delta):
	if not player:
		current_state = EnemyState.IDLE
		return

	_face_player()
	var dir = (player.global_position - global_position).normalized()
	velocity.x = dir.x * move_speed

	# Slow movement - slime is sluggish
	velocity.x *= slow_amount

	if global_position.distance_to(player.global_position) <= attack_range:
		current_state = EnemyState.ATTACK

func _perform_attack():
	can_attack = false
	_face_player()
	await get_tree().create_timer(0.4).timeout
	if player and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist <= attack_range * 1.5 and player.has_method("take_damage"):
			player.take_damage(attack_power, self)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	current_state = EnemyState.CHASE

func die():
	if split_count > 0 and not _is_split:
		_split()
	super.die()

func _split():
	_is_split = true
	# Spawn smaller slimes
	for i in range(2):
		var small_slime = duplicate()
		small_slime.set_script(get_script())
		small_slime._is_split = true
		small_slime.split_count = 0
		small_slime.max_health = max_health / 2
		small_slime.current_health = small_slime.max_health
		small_slime.attack_power = attack_power / 2
		small_slime.move_speed = move_speed * 1.3
		small_slime.scale = Vector2(0.7, 0.7)
		small_slime.global_position = global_position + Vector2(randf_range(-20, 20), -10)
		get_parent().add_child(small_slime)
