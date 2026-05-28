class_name EnemyBase
extends CharacterBody2D

@export var max_health: int = 35
@export var attack_power: int = 8
@export var move_speed: float = 70.0
@export var detection_range: float = 150.0
@export var attack_range: float = 25.0
@export var monster_texture: Texture2D

var current_health: int
var player: Node2D = null
var is_dead: bool = false
var can_attack: bool = true
var attack_cooldown: float = 1.0
var facing_right: bool = true

enum EnemyState { IDLE, PATROL, CHASE, ATTACK, HIT, DEAD }
var current_state: EnemyState = EnemyState.IDLE

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var hurtbox: Area2D = $Hurtbox

var hit_flash_node: Node

func _ready():
	current_health = max_health
	add_to_group("enemies")
	_setup_enemy_sprite()
	_setup_connections()

func _setup_enemy_sprite():
	if monster_texture:
		sprite.visible = false
		var tex_sprite = Sprite2D.new()
		tex_sprite.name = "MonsterSprite"
		tex_sprite.texture = monster_texture
		tex_sprite.centered = true
		tex_sprite.offset = Vector2(0, -12)
		add_child(tex_sprite)
		hit_flash_node = preload("res://scripts/combat/HitFlash.gd").new()
		hit_flash_node.name = "HitFlash"
		add_child(hit_flash_node)
		hit_flash_node.setup(tex_sprite)
	else:
		sprite.visible = false
		var color_rect = ColorRect.new()
		color_rect.name = "EnemyVisual"
		color_rect.size = Vector2(16, 24)
		color_rect.position = Vector2(-8, -24)
		color_rect.color = Color(0.8, 0.2, 0.2, 1)
		add_child(color_rect)

func _setup_connections():
	if detection_area:
		detection_area.body_entered.connect(_on_detection_entered)
		detection_area.body_exited.connect(_on_detection_exited)
	if hurtbox and hurtbox.has_signal("hurt"):
		hurtbox.hurt.connect(_on_hurt)

func _physics_process(delta):
	if is_dead:
		return
	if not is_on_floor():
		velocity.y += 900 * delta
		velocity.y = min(velocity.y, 520)
	match current_state:
		EnemyState.IDLE:
			_idle_state(delta)
		EnemyState.PATROL:
			_patrol_state(delta)
		EnemyState.CHASE:
			_chase_state(delta)
		EnemyState.ATTACK:
			_attack_state(delta)
		EnemyState.HIT:
			_hit_state(delta)
	move_and_slide()

func _idle_state(_delta):
	velocity.x = move_toward(velocity.x, 0, 500 * _delta)
	if player:
		current_state = EnemyState.CHASE

func _patrol_state(_delta):
	pass

func _chase_state(_delta):
	if not player:
		current_state = EnemyState.IDLE
		return
	var dir = (player.global_position - global_position).normalized()
	velocity.x = dir.x * move_speed
	_face_player()
	if global_position.distance_to(player.global_position) <= attack_range:
		current_state = EnemyState.ATTACK

func _attack_state(_delta):
	velocity.x = move_toward(velocity.x, 0, 500 * _delta)
	if can_attack:
		_perform_attack()

func _hit_state(_delta):
	pass

func _perform_attack():
	can_attack = false
	_face_player()
	await get_tree().create_timer(0.3).timeout
	if player and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist <= attack_range * 1.5 and player.has_method("take_damage"):
			player.take_damage(attack_power, self)
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	current_state = EnemyState.CHASE

func _face_player():
	if player:
		if player.global_position.x < global_position.x and facing_right:
			_flip()
		elif player.global_position.x > global_position.x and not facing_right:
			_flip()

func _flip():
	facing_right = not facing_right
	sprite.flip_h = not facing_right
	var tex_sprite = get_node_or_null("MonsterSprite")
	if tex_sprite:
		tex_sprite.flip_h = not facing_right

func _on_detection_entered(body: Node2D):
	if body.name == "Player" or body.is_in_group("player"):
		player = body
		current_state = EnemyState.CHASE

func _on_detection_exited(body: Node2D):
	if body == player:
		player = null
		current_state = EnemyState.IDLE

func _on_hurt(damage: int, knockback: Vector2, source: Node):
	current_health -= damage
	EventBus.enemy_hit.emit(self, damage)
	# Feedback
	FeedbackManager.damage_text(global_position + Vector2(0, -20), damage)
	FeedbackManager.hit_stop(0.03)
	if hit_flash_node and hit_flash_node.has_method("flash"):
		hit_flash_node.flash()
	if current_health <= 0:
		die()
	else:
		current_state = EnemyState.HIT
		velocity = knockback
		await get_tree().create_timer(0.2).timeout
		if not is_dead:
			current_state = EnemyState.CHASE

func die():
	is_dead = true
	current_state = EnemyState.DEAD
	velocity = Vector2.ZERO
	EventBus.enemy_died.emit(self)
	_spawn_death_loot()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	queue_free()

func _spawn_death_loot():
	var enemy_type = "normal"
	if self.get_script() and self.get_script().resource_path.ends_with("BossBase.gd"):
		enemy_type = "boss"
	elif max_health >= 50:
		enemy_type = "elite"
	var loot_manager = get_node_or_null("/root/LootManager")
	if not loot_manager:
		loot_manager = load("res://scripts/items/LootManager.gd").new()
		add_child(loot_manager)
	var drops = loot_manager.roll_loot(enemy_type)
	_spawn_drops(drops)

func _spawn_drops(drops: Array):
	var item_textures = {
		"gold": "res://assets/dungeon_crawl/items/misc/face1_gold.png",
		"key": "res://assets/dungeon_crawl/items/misc/celtic_blue.png",
		"small_potion": "res://assets/dungeon_crawl/items/potions/emerald.png",
		"big_potion": "res://assets/dungeon_crawl/items/potions/brilliant_blue.png",
		"iron_sword": "res://assets/dungeon_crawl/items/weapons/short_sword1.png",
		"knight_sword": "res://assets/dungeon_crawl/items/weapons/long_sword1.png",
	}
	for drop_data in drops:
		var item_id = drop_data.get("id", "")
		var drop_type = drop_data.get("type", "")
		var tex_path = ""
		if drop_type == "gold":
			tex_path = item_textures.get("gold", "")
		elif item_id != "":
			tex_path = item_textures.get(item_id, "")
		var drop_script = load("res://scripts/items/ItemDrop.gd")
		var drop_node = Area2D.new()
		drop_node.set_script(drop_script)
		get_parent().add_child(drop_node)
		var full_data = drop_data.duplicate()
		full_data["texture"] = tex_path
		if drop_type == "gold":
			full_data["type"] = "gold"
		elif drop_data.get("data", {}).has("type"):
			full_data["type"] = drop_data["data"]["type"]
		drop_node.setup(full_data, null, global_position + Vector2(randf_range(-10, 10), 0))
