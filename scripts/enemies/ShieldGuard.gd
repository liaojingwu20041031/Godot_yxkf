extends EnemyBase

var block_chance: float = 0.6
var is_blocking: bool = false
var shield_sprite: Sprite2D

func _ready():
	max_health = 60
	attack_power = 12
	move_speed = 45.0
	detection_range = 100.0
	attack_range = 28.0
	attack_cooldown = 1.5
	monster_texture = load("res://assets/dungeon_crawl/monsters/deep_elf_knight.png")
	super._ready()
	_create_shield()

func _create_shield():
	# Create a shield collision box in front of the guard
	shield_sprite = Sprite2D.new()
	shield_sprite.name = "ShieldSprite"
	# Create a simple shield texture
	var img = Image.create(8, 20, false, Image.FORMAT_RGBA8)
	for x in range(8):
		for y in range(20):
			var edge = (x == 0 or x == 7 or y == 0 or y == 19)
			if edge:
				img.set_pixel(x, y, Color(0.6, 0.5, 0.3, 1.0))
			else:
				img.set_pixel(x, y, Color(0.4, 0.4, 0.5, 0.9))
	var tex = ImageTexture.create_from_image(img)
	shield_sprite.texture = tex
	shield_sprite.position = Vector2(14, -8)
	add_child(shield_sprite)

	# Shield collision area for blocking
	var shield_area = Area2D.new()
	shield_area.name = "ShieldBlock"
	shield_area.collision_layer = 0
	shield_area.collision_mask = 4  # player_hitbox
	var shield_col = CollisionShape2D.new()
	var shield_shape = RectangleShape2D.new()
	shield_shape.size = Vector2(6, 20)
	shield_col.shape = shield_shape
	shield_area.add_child(shield_col)
	add_child(shield_area)

func _chase_state(delta):
	if not player:
		current_state = EnemyState.IDLE
		return

	_face_player()
	var dir = (player.global_position - global_position).normalized()
	velocity.x = dir.x * move_speed

	# Block when player is facing us (we face away from player)
	is_blocking = (player.global_position.x < global_position.x and facing_right) or \
				  (player.global_position.x > global_position.x and not facing_right)

	# Update shield visual position
	if shield_sprite:
		shield_sprite.visible = is_blocking
		shield_sprite.position.x = 14 if facing_right else -14

	if global_position.distance_to(player.global_position) <= attack_range:
		current_state = EnemyState.ATTACK

func _on_hurt(damage: int, knockback: Vector2, source: Node):
	if is_blocking:
		damage = int(damage * (1.0 - block_chance))
		knockback *= 0.3
	super._on_hurt(damage, knockback, source)

func _perform_attack():
	can_attack = false
	_face_player()
	is_blocking = false
	if shield_sprite:
		shield_sprite.visible = false
	await get_tree().create_timer(0.5).timeout
	if attack_area:
		for body in attack_area.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(attack_power, self)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	current_state = EnemyState.CHASE
