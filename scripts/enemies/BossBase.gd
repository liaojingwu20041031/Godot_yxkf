extends EnemyBase

@export var boss_name: String = "腐败地牢骑士"
@export var phase2_threshold: float = 0.5

var current_phase: int = 1
var phase2_attack_boost: float = 1.2
var summon_timer: float = 0.0
var summon_interval: float = 15.0

var shadow_flame_scene: PackedScene

func _ready():
	max_health = 450
	attack_power = 18
	move_speed = 80.0
	detection_range = 300.0
	attack_range = 40.0
	attack_cooldown = 1.5
	monster_texture = load("res://assets/dungeon_crawl/monsters/hell_knight.png")
	super._ready()
	EventBus.boss_phase_changed.emit(1)

func _physics_process(delta):
	super._physics_process(delta)

	if current_phase == 2:
		summon_timer += delta
		if summon_timer >= summon_interval:
			summon_timer = 0.0
			_summon_skeletons()

func _chase_state(delta):
	if not player:
		current_state = EnemyState.IDLE
		return

	var dist = global_position.distance_to(player.global_position)
	_face_player()

	if dist > attack_range * 1.5:
		var dir = (player.global_position - global_position).normalized()
		velocity.x = dir.x * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, 800 * delta)
		if can_attack:
			_choose_attack(dist)

func _choose_attack(dist: float):
	var attacks = ["horizontal_slash", "jump_slash", "shadow_charge"]
	if current_phase == 2:
		attacks.append("triple_slash")
		attacks.append("summon")

	var attack = attacks[randi() % attacks.size()]
	match attack:
		"horizontal_slash":
			_attack_horizontal_slash()
		"jump_slash":
			_attack_jump_slash()
		"shadow_charge":
			_attack_shadow_charge()
		"triple_slash":
			_attack_triple_slash()
		"summon":
			_summon_skeletons()

func _attack_horizontal_slash():
	can_attack = false
	sprite.play("attack")
	await get_tree().create_timer(0.4).timeout
	var damage_mult = phase2_attack_boost if current_phase == 2 else 1.0
	if attack_area:
		for body in attack_area.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(int(attack_power * damage_mult), self)
	await sprite.animation_finished
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _attack_jump_slash():
	can_attack = false
	if player:
		var target_pos = player.global_position
		var jump_time = 0.5
		var jump_height = 100.0
		var start_pos = global_position

		var tween = create_tween()
		tween.tween_property(self, "position", Vector2(target_pos.x, start_pos.y - jump_height), jump_time * 0.5)
		tween.tween_property(self, "position", Vector2(target_pos.x, target_pos.y), jump_time * 0.5)

		await tween.finished
		sprite.play("attack")
		await get_tree().create_timer(0.2).timeout

		for body in attack_area.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(int(attack_power * 1.3), self)

		await get_tree().create_timer(0.5).timeout
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _attack_shadow_charge():
	can_attack = false
	sprite.play("dash")
	var dir = 1 if facing_right else -1
	var charge_speed = 300.0
	velocity.x = charge_speed * dir

	await get_tree().create_timer(0.3).timeout

	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(int(attack_power * 1.2), self)

	velocity.x = 0
	await get_tree().create_timer(0.3).timeout

	if current_phase == 2:
		_attack_backhand_slash()

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _attack_triple_slash():
	can_attack = false
	for i in range(3):
		sprite.play("attack")
		await get_tree().create_timer(0.3).timeout
		for body in attack_area.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(attack_power, self)
		await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(attack_cooldown * 1.5).timeout
	can_attack = true

func _attack_backhand_slash():
	sprite.play("attack")
	await get_tree().create_timer(0.2).timeout
	for body in attack_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(int(attack_power * 0.8), self)

func _summon_skeletons():
	for i in range(2):
		var skeleton = preload("res://scenes/enemies/Skeleton.tscn").instantiate()
		skeleton.position = global_position + Vector2(randf_range(-50, 50), -20)
		get_parent().add_child(skeleton)

func _on_hurt(damage: int, knockback: Vector2, source: Node):
	super._on_hurt(damage, knockback, source)

	var health_percent = float(current_health) / float(max_health)
	if health_percent <= phase2_threshold and current_phase == 1:
		_enter_phase2()

func _enter_phase2():
	current_phase = 2
	attack_power = int(attack_power * phase2_attack_boost)
	move_speed *= 1.15
	attack_cooldown *= 0.8
	EventBus.boss_phase_changed.emit(2)
	_spawn_shadow_flames()

func _spawn_shadow_flames():
	for i in range(3):
		var flame_pos = global_position + Vector2(randf_range(-100, 100), 0)
		var flame = Area2D.new()
		flame.position = flame_pos
		var col = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 15.0
		col.shape = shape
		flame.add_child(col)
		get_parent().add_child(flame)
		flame.body_entered.connect(func(body):
			if body.has_method("take_damage") and body.is_in_group("player"):
				body.take_damage(5, self)
		)
		var timer = get_tree().create_timer(8.0)
		timer.timeout.connect(flame.queue_free)

func die():
	is_dead = true
	current_state = EnemyState.DEAD
	velocity = Vector2.ZERO
	EventBus.boss_died.emit()
	sprite.play("death")
	await sprite.animation_finished
	EventBus.game_over.emit(true)
	queue_free()
