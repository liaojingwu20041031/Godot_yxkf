extends EnemyBase

var preferred_distance: float = 100.0
var retreat_distance: float = 60.0

func _ready():
	max_health = 28
	attack_power = 10
	move_speed = 50.0
	detection_range = 180.0
	attack_range = 140.0
	attack_cooldown = 1.5
	monster_texture = load("res://assets/dungeon_crawl/monsters/deep_elf_mage.png")
	super._ready()

func _chase_state(delta):
	if not player:
		current_state = EnemyState.IDLE
		return

	var dist = global_position.distance_to(player.global_position)
	_face_player()

	if dist < retreat_distance:
		var dir = (global_position - player.global_position).normalized()
		velocity.x = dir.x * move_speed
	elif dist > preferred_distance * 1.2:
		var dir = (player.global_position - global_position).normalized()
		velocity.x = dir.x * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, 500 * delta)

	if dist <= attack_range:
		current_state = EnemyState.ATTACK

func _perform_attack():
	can_attack = false
	_face_player()
	await get_tree().create_timer(0.5).timeout
	_shoot_fireball()
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	current_state = EnemyState.CHASE

func _shoot_fireball():
	var fireball = Area2D.new()
	fireball.position = global_position
	fireball.collision_layer = 64  # projectiles layer
	fireball.collision_mask = 1    # player layer
	var dir = 1 if facing_right else -1
	fireball.set_meta("direction", dir)
	fireball.set_meta("damage", attack_power)
	fireball.set_meta("speed", 120.0)

	var col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 5.0
	col.shape = shape
	fireball.add_child(col)

	# Fireball visual - orange-red circle with glow
	var fb_sprite = Sprite2D.new()
	fb_sprite.name = "FireballSprite"
	# Create a simple fireball texture programmatically
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	for x in range(16):
		for y in range(16):
			var dist = Vector2(x - 8, y - 8).length()
			if dist < 7:
				var t = dist / 7.0
				var color = Color(1.0, 0.9, 0.2, 1.0).lerp(Color(1.0, 0.3, 0.0, 0.8), t)
				if dist > 5:
					color.a = 0.5
				img.set_pixel(x, y, color)
	var tex = ImageTexture.create_from_image(img)
	fb_sprite.texture = tex
	fb_sprite.scale = Vector2(1.5, 1.5)
	fireball.add_child(fb_sprite)

	# Add point light for glow
	var light = PointLight2D.new()
	light.color = Color(1.0, 0.6, 0.1, 0.8)
	light.energy = 0.8
	light.texture_scale = 0.3
	fireball.add_child(light)

	get_parent().add_child(fireball)
	fireball.global_position = global_position + Vector2(dir * 20, -4)

	var move_tween = create_tween()
	var target_pos = fireball.global_position + Vector2(dir * 300, 0)
	move_tween.tween_property(fireball, "global_position", target_pos, 2.5).set_ease(Tween.EASE_IN)

	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(func():
		if is_instance_valid(fireball):
			fireball.queue_free()
	)

	fireball.body_entered.connect(func(body):
		if body.has_method("take_damage") and body.is_in_group("player"):
			body.take_damage(attack_power, self)
			if is_instance_valid(fireball):
				fireball.queue_free()
	)
