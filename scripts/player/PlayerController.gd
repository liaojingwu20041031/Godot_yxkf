extends CharacterBody2D

# Movement constants
const MOVE_SPEED: float = 160.0
const GROUND_ACCEL: float = 1800.0
const GROUND_FRICTION: float = 2200.0
const AIR_ACCEL: float = 1000.0
const GRAVITY: float = 900.0
const FALL_GRAVITY_MULT: float = 1.5
const MAX_FALL_SPEED: float = 520.0
const JUMP_VELOCITY: float = -330.0
const SHORT_JUMP_MULT: float = 0.5

# Dash constants
const DASH_SPEED: float = 420.0
const DASH_DURATION: float = 0.16
const DASH_COOLDOWN: float = 0.8

# Roll constants
const ROLL_SPEED: float = 260.0
const ROLL_DURATION: float = 0.35
const ROLL_INVULN_TIME: float = 0.28
const ROLL_COOLDOWN: float = 0.5

# Coyote time and jump buffer
const COYOTE_TIME: float = 0.12
const JUMP_BUFFER_TIME: float = 0.12

# Wall mechanics
const WALL_SLIDE_SPEED: float = 60.0
const WALL_JUMP_X: float = 200.0
const WALL_JUMP_Y: float = -300.0
const WALL_CLIMB_SPEED: float = -80.0

# State machine
enum State {
	IDLE, RUN, TURN, CROUCH, CROUCH_WALK, CROUCH_ATTACK,
	SLIDE, JUMP, FALL, ATTACK_1, ATTACK_2, ATTACK_COMBO,
	DASH, ROLL, WALL_SLIDE, WALL_CLIMB, HANG, HIT, DEAD
}

var current_state: State = State.IDLE
var facing_right: bool = true
var can_double_jump: bool = false
var has_double_jumped: bool = false
var air_dash_count: int = 0
var max_air_dashes: int = 1

# Timers
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var roll_timer: float = 0.0
var roll_cooldown_timer: float = 0.0
var hit_timer: float = 0.0
var invuln_timer: float = 0.0
var attack_combo_timer: float = 0.0

# State flags
var is_dashing: bool = false
var is_rolling: bool = false
var is_invulnerable: bool = false
var is_attacking: bool = false
var attack_queued: bool = false
var is_crouching: bool = false
var is_wall_sliding: bool = false
var is_wall_climbing: bool = false
var was_on_floor: bool = false

# Combo system
var combo_count: int = 0
const MAX_COMBO: int = 3
const COMBO_WINDOW: float = 0.6

# References
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var attack_pivot: Node2D = $AttackPivot
@onready var attack_hitbox: Area2D = $AttackPivot/AttackHitbox
@onready var ground_check: RayCast2D = $GroundCheck
@onready var wall_check_left: RayCast2D = $WallCheckLeft
@onready var wall_check_right: RayCast2D = $WallCheckRight

# Stats
var max_health: int = 100
var current_health: int = 100
var attack_power: int = 10
var defense: int = 0
var shield: int = 0

func _ready():
	current_health = max_health
	add_to_group("player")
	_setup_animations()
	EventBus.player_health_changed.emit(current_health, max_health)
	EventBus.enemy_died.connect(_on_enemy_died)

func _setup_animations():
	var frames = SpriteFrames.new()
	var anims = {
		"idle": ["res://assets/free_knight/_Idle.png", 10, 8, true],
		"run": ["res://assets/free_knight/_Run.png", 10, 10, true],
		"jump": ["res://assets/free_knight/_Jump.png", 3, 8, false],
		"fall": ["res://assets/free_knight/_Fall.png", 3, 8, true],
		"attack": ["res://assets/free_knight/_Attack.png", 4, 10, false],
		"attack2": ["res://assets/free_knight/_Attack2.png", 6, 10, false],
		"attack_combo": ["res://assets/free_knight/_AttackCombo.png", 6, 12, false],
		"dash": ["res://assets/free_knight/_Dash.png", 2, 8, false],
		"roll": ["res://assets/free_knight/_Roll.png", 12, 12, false],
		"wall_slide": ["res://assets/free_knight/_WallSlide.png", 3, 8, true],
		"wall_climb": ["res://assets/free_knight/_WallClimb.png", 7, 8, true],
		"wall_hang": ["res://assets/free_knight/_WallHang.png", 1, 8, false],
		"crouch": ["res://assets/free_knight/_Crouch.png", 1, 8, false],
		"crouch_walk": ["res://assets/free_knight/_CrouchWalk.png", 8, 8, true],
		"crouch_attack": ["res://assets/free_knight/_CrouchAttack.png", 4, 10, false],
		"turn": ["res://assets/free_knight/_TurnAround.png", 3, 8, false],
		"slide": ["res://assets/free_knight/_Slide.png", 2, 8, false],
		"hit": ["res://assets/free_knight/_Hit.png", 1, 8, false],
		"death": ["res://assets/free_knight/_Death.png", 10, 8, false]
	}
	var has_textures = false
	for anim_name in anims:
		var data = anims[anim_name]
		var tex = load(data[0])
		if not tex:
			continue
		has_textures = true
		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, data[2])
		frames.set_animation_loop(anim_name, data[3])
		for i in range(data[1]):
			var atlas = AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * 120, 0, 120, 80)
			frames.add_frame(anim_name, atlas)
	if has_textures:
		sprite.sprite_frames = frames
		sprite.play("idle")
	else:
		sprite.visible = false
		var color_rect = ColorRect.new()
		color_rect.name = "PlayerVisual"
		color_rect.size = Vector2(16, 28)
		color_rect.position = Vector2(-8, -28)
		color_rect.color = Color(0.3, 0.5, 1.0, 1)
		add_child(color_rect)

func _physics_process(delta):
	if current_state == State.DEAD:
		return

	_update_timers(delta)
	_handle_input(delta)
	_apply_gravity(delta)
	_update_state()
	_update_animation()
	move_and_slide()
	_post_movement_check()

func _update_timers(delta):
	coyote_timer = max(0.0, coyote_timer - delta)
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
	dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)
	roll_cooldown_timer = max(0.0, roll_cooldown_timer - delta)
	hit_timer = max(0.0, hit_timer - delta)
	invuln_timer = max(0.0, invuln_timer - delta)
	attack_combo_timer = max(0.0, attack_combo_timer - delta)

	if invuln_timer <= 0.0:
		is_invulnerable = false
		_enable_hurtbox()

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false

	if is_rolling:
		roll_timer -= delta
		if roll_timer <= 0.0:
			is_rolling = false

func _handle_input(delta):
	if current_state == State.HIT or current_state == State.DEAD:
		return

	if is_dashing or is_rolling:
		return

	if is_attacking:
		if Input.is_action_just_pressed("attack"):
			attack_queued = true
		return

	# Crouch
	is_crouching = Input.is_action_pressed("crouch") and is_on_floor()

	# Movement
	var speed_mult = get_meta("speed_multiplier", 1.0)
	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir != 0 and not is_crouching:
		var accel = GROUND_ACCEL if is_on_floor() else AIR_ACCEL
		velocity.x = move_toward(velocity.x, input_dir * MOVE_SPEED * speed_mult, accel * delta)
		if input_dir > 0 and not facing_right:
			_flip()
		elif input_dir < 0 and facing_right:
			_flip()
	else:
		var friction = GROUND_FRICTION if is_on_floor() else AIR_ACCEL * 0.5
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	# Jump
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	if jump_buffer_timer > 0 and (is_on_floor() or coyote_timer > 0):
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0
		has_double_jumped = false
		air_dash_count = 0

	# Short jump
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= SHORT_JUMP_MULT

	# Double jump (if unlocked)
	if can_double_jump and not is_on_floor() and not has_double_jumped:
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY * 0.85
			has_double_jumped = true

	# Dash
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0:
		if is_on_floor() or air_dash_count < max_air_dashes:
			_start_dash()
			if not is_on_floor():
				air_dash_count += 1

	# Roll
	if Input.is_action_just_pressed("roll") and roll_cooldown_timer <= 0 and is_on_floor():
		_start_roll()

	# Attack (combo system)
	if Input.is_action_just_pressed("attack"):
		_start_attack()

	# Wall mechanics
	_handle_wall_mechanics()

func _handle_wall_mechanics():
	if is_on_floor():
		is_wall_sliding = false
		is_wall_climbing = false
		return

	var on_wall = wall_check_left.is_colliding() or wall_check_right.is_colliding()
	if not on_wall:
		is_wall_sliding = false
		is_wall_climbing = false
		return

	var wall_dir = -1 if wall_check_left.is_colliding() else 1

	# Wall climb: press up while on wall
	if Input.is_action_pressed("jump") and velocity.y < 0:
		is_wall_climbing = true
		is_wall_sliding = false
		velocity.y = WALL_CLIMB_SPEED
		velocity.x = 0
	elif velocity.y > 0:
		# Wall slide: falling while on wall
		is_wall_sliding = true
		is_wall_climbing = false
		velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
	else:
		is_wall_sliding = false
		is_wall_climbing = false

	# Wall jump
	if Input.is_action_just_pressed("jump"):
		velocity.x = WALL_JUMP_X * -wall_dir
		velocity.y = WALL_JUMP_Y
		is_wall_sliding = false
		is_wall_climbing = false

func _apply_gravity(delta):
	if is_dashing or is_rolling:
		return
	if is_wall_climbing:
		return
	if not is_on_floor():
		var grav = GRAVITY
		if velocity.y > 0:
			grav *= FALL_GRAVITY_MULT
		if is_wall_sliding:
			grav *= 0.3
		velocity.y = min(velocity.y + grav * delta, MAX_FALL_SPEED)

func _start_dash():
	is_dashing = true
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
	var dir = 1 if facing_right else -1
	velocity.x = DASH_SPEED * dir
	velocity.y = 0
	# I-frame: disable hurtbox during dash
	_disable_hurtbox()
	invuln_timer = DASH_DURATION
	is_invulnerable = true

func _start_roll():
	is_rolling = true
	roll_timer = ROLL_DURATION
	roll_cooldown_timer = ROLL_COOLDOWN
	invuln_timer = ROLL_INVULN_TIME
	is_invulnerable = true
	var dir = 1 if facing_right else -1
	velocity.x = ROLL_SPEED * dir
	# I-frame: disable hurtbox during roll
	_disable_hurtbox()

func _disable_hurtbox():
	if hurtbox and hurtbox.has_node("CollisionShape2D"):
		hurtbox.get_node("CollisionShape2D").disabled = true

func _enable_hurtbox():
	if hurtbox and hurtbox.has_node("CollisionShape2D"):
		hurtbox.get_node("CollisionShape2D").disabled = false

# ── Combo System ──────────────────────────────────────────────
func _start_attack():
	if is_attacking:
		# Queue next hit in combo
		if attack_combo_timer > 0:
			attack_queued = true
		return
	combo_count = 0
	_do_attack_combo()

func _do_attack_combo():
	is_attacking = true
	combo_count += 1
	attack_combo_timer = COMBO_WINDOW
	attack_queued = false

	match combo_count:
		1:
			current_state = State.ATTACK_1
			_enable_attack_hitbox(attack_power)
			await get_tree().create_timer(0.25).timeout
			_disable_attack_hitbox()
			await get_tree().create_timer(0.15).timeout
		2:
			current_state = State.ATTACK_2
			_enable_attack_hitbox(int(attack_power * 1.4))
			await get_tree().create_timer(0.3).timeout
			_disable_attack_hitbox()
			await get_tree().create_timer(0.15).timeout
		3:
			current_state = State.ATTACK_COMBO
			_enable_attack_hitbox(int(attack_power * 2.0))
			await get_tree().create_timer(0.4).timeout
			_disable_attack_hitbox()
			await get_tree().create_timer(0.2).timeout

	if attack_queued and combo_count < MAX_COMBO:
		attack_queued = false
		_do_attack_combo()
	else:
		is_attacking = false
		combo_count = 0

func _enable_attack_hitbox(damage: int):
	var kb_dir = Vector2.RIGHT if facing_right else Vector2.LEFT
	attack_hitbox.set_damage(damage)
	attack_hitbox.set_knockback(kb_dir, 150.0)
	attack_hitbox.owner_node = self
	attack_hitbox.get_node("CollisionShape2D").disabled = false

func _disable_attack_hitbox():
	attack_hitbox.get_node("CollisionShape2D").disabled = true

func _flip():
	facing_right = not facing_right
	sprite.flip_h = not facing_right
	attack_pivot.scale.x = 1 if facing_right else -1

func _update_state():
	if current_state == State.DEAD:
		return
	if current_state == State.HIT and hit_timer > 0:
		return
	if is_dashing:
		current_state = State.DASH
		return
	if is_rolling:
		current_state = State.ROLL
		return
	if is_attacking:
		return
	if is_wall_climbing:
		current_state = State.WALL_CLIMB
		return
	if is_wall_sliding:
		current_state = State.WALL_SLIDE
		return

	if is_on_floor():
		if is_crouching:
			var input_dir = Input.get_axis("move_left", "move_right")
			if abs(input_dir) > 0:
				current_state = State.CROUCH_WALK
			else:
				current_state = State.CROUCH
		elif abs(velocity.x) > 10:
			current_state = State.RUN
		else:
			current_state = State.IDLE
	else:
		if velocity.y < 0:
			current_state = State.JUMP
		else:
			current_state = State.FALL

func _update_animation():
	match current_state:
		State.IDLE:
			sprite.play("idle")
		State.RUN:
			sprite.play("run")
		State.JUMP:
			sprite.play("jump")
		State.FALL:
			sprite.play("fall")
		State.ATTACK_1:
			sprite.play("attack")
		State.ATTACK_2:
			sprite.play("attack2")
		State.ATTACK_COMBO:
			sprite.play("attack_combo")
		State.DASH:
			sprite.play("dash")
		State.ROLL:
			sprite.play("roll")
		State.WALL_SLIDE:
			sprite.play("wall_slide")
		State.WALL_CLIMB:
			sprite.play("wall_climb")
		State.HANG:
			sprite.play("wall_hang")
		State.CROUCH:
			sprite.play("crouch")
		State.CROUCH_WALK:
			sprite.play("crouch_walk")
		State.CROUCH_ATTACK:
			sprite.play("crouch_attack")
		State.TURN:
			sprite.play("turn")
		State.SLIDE:
			sprite.play("slide")
		State.HIT:
			sprite.play("hit")
		State.DEAD:
			sprite.play("death")

func _post_movement_check():
	if is_on_floor():
		air_dash_count = 0
		has_double_jumped = false
		coyote_timer = COYOTE_TIME

	was_on_floor = is_on_floor()

func take_damage(damage: int, source: Node = null):
	if is_invulnerable or current_state == State.DEAD:
		return

	var actual_damage = max(0, damage - defense)
	if shield > 0:
		var shield_absorb = min(shield, actual_damage)
		shield -= shield_absorb
		actual_damage -= shield_absorb
		EventBus.player_shield_changed.emit(shield, max_health)

	current_health -= actual_damage
	EventBus.player_health_changed.emit(current_health, max_health)
	EventBus.player_hit.emit(actual_damage, source)
	# Show damage floating text
	if actual_damage > 0:
		var ft = FloatingText.new()
		ft.text = str(actual_damage)
		ft.color = Color(1, 0.2, 0.2, 1)
		ft.font_size = 14
		ft.global_position = global_position + Vector2(0, -30)
		get_parent().add_child(ft)

	if current_health <= 0:
		_die()
	else:
		_enter_hit_state()

func _enter_hit_state():
	current_state = State.HIT
	hit_timer = 0.3
	invuln_timer = 0.8
	is_invulnerable = true
	is_attacking = false
	is_dashing = false
	is_rolling = false
	_disable_hurtbox()
	var knockback_dir = 1 if facing_right else -1
	velocity.x = -knockback_dir * 150
	velocity.y = -100

func _die():
	current_state = State.DEAD
	velocity = Vector2.ZERO
	sprite.play("death")
	EventBus.player_died.emit()
	await sprite.animation_finished
	EventBus.game_over.emit(false)

func heal(amount: int):
	current_health = min(current_health + amount, max_health)
	EventBus.player_health_changed.emit(current_health, max_health)
	# Show healing floating text
	var ft = FloatingText.new()
	ft.text = "+%d HP" % amount
	ft.color = Color(0.3, 1, 0.3, 1)
	ft.font_size = 14
	ft.global_position = global_position + Vector2(0, -30)
	get_parent().add_child(ft)

func add_shield(amount: int):
	shield = min(shield + amount, max_health)
	EventBus.player_shield_changed.emit(shield, max_health)

func _on_enemy_died(_enemy: Node):
	# Lifesteal: heal on kill
	var kill_heal = get_meta("on_kill_health", 0)
	if kill_heal > 0:
		heal(kill_heal)

func get_state() -> State:
	return current_state
