extends Node2D

signal room_cleared
signal all_enemies_dead

enum RoomType { START, COMBAT, ELITE, TREASURE, SHOP, REST, SHRINE, BOSS }

@export var room_type: RoomType = RoomType.COMBAT
@export var room_layout: String = "standard"
@export var floor_variant: int = 0
@export var enemies_to_spawn: Array[PackedScene] = []
@export var spawn_points: Array[Vector2] = []

var enemies_alive: int = 0
var is_cleared: bool = false
var is_active: bool = false
var tracked_enemies: Array[Node] = []

@onready var entrance_door: StaticBody2D = get_node_or_null("EntranceDoor")
@onready var exit_door: StaticBody2D = get_node_or_null("ExitDoor")
@onready var enemy_container: Node2D = get_node_or_null("EnemyContainer")
@onready var reward_point: Marker2D = get_node_or_null("RewardPoint")

func _ready():
	# Generate tilemap using DungeonTileset
	_setup_tilemap()

	# Exit door starts closed (except for safe rooms)
	if room_type == RoomType.START:
		# Start room: both doors open
		if exit_door and exit_door.has_method("open"):
			exit_door.open()
	else:
		# Combat/treasure/etc: exit closed until cleared
		if exit_door and exit_door.has_method("close"):
			exit_door.close()

	# Entrance door starts open
	if entrance_door and entrance_door.has_method("open"):
		entrance_door.open()

	# Connect exit detection area
	if exit_door and exit_door.has_node("ExitDetection"):
		var exit_detection = exit_door.get_node("ExitDetection")
		exit_detection.body_entered.connect(_on_exit_body_entered)

	EventBus.enemy_died.connect(_on_enemy_died)

	if room_type == RoomType.COMBAT or room_type == RoomType.ELITE or room_type == RoomType.BOSS:
		call_deferred("activate")
	elif room_type == RoomType.TREASURE:
		call_deferred("activate")
	elif room_type == RoomType.SHOP:
		call_deferred("activate")
	elif room_type == RoomType.REST:
		call_deferred("activate")

func _setup_tilemap():
	# Add main collision tilemap
	if has_node("DungeonTileMap"):
		return

	# Add background tilemap first (behind everything)
	if not has_node("BackgroundTileMap"):
		var bg_tilemap = DungeonTileset.create_background_tilemap()
		add_child(bg_tilemap)
		move_child(bg_tilemap, 0)
	var floor_source = floor_variant if floor_variant >= 0 else 0
	var wall_source = 2 if floor_variant == 0 else 3
	var tilemap = DungeonTileset.create_room_tilemap(room_layout, floor_source, wall_source)
	add_child(tilemap)
	move_child(tilemap, 1)

func activate():
	is_active = true
	EventBus.room_entered.emit(RoomType.keys()[room_type])

	if room_type == RoomType.COMBAT or room_type == RoomType.ELITE or room_type == RoomType.BOSS:
		_close_entrance()
		_spawn_enemies()
	elif room_type == RoomType.TREASURE:
		_spawn_treasure()
	elif room_type == RoomType.SHOP:
		_spawn_shop()
	elif room_type == RoomType.REST:
		_spawn_rest()

func _close_entrance():
	if entrance_door:
		if entrance_door.has_method("close"):
			entrance_door.close()

func _open_exit():
	if exit_door:
		if exit_door.has_method("open"):
			exit_door.open()
	is_cleared = true
	room_cleared.emit()

func _open_entrance():
	if entrance_door:
		if entrance_door.has_method("open"):
			entrance_door.open()

func _spawn_enemies():
	# Count pre-placed enemies in EnemyContainer
	if enemy_container:
		for child in enemy_container.get_children():
			if child.is_in_group("enemies"):
				enemies_alive += 1
				tracked_enemies.append(child)
	# Also spawn from enemies_to_spawn array
	for i in range(enemies_to_spawn.size()):
		var enemy_scene = enemies_to_spawn[i]
		var spawn_pos = spawn_points[i] if i < spawn_points.size() else Vector2(randf_range(50, 250), 100)
		var enemy = enemy_scene.instantiate()
		enemy.position = spawn_pos
		enemy_container.add_child(enemy)
		enemies_alive += 1
		tracked_enemies.append(enemy)

func _spawn_treasure():
	# Find chest in PropContainer and connect
	var prop_container = get_node_or_null("PropContainer")
	if prop_container:
		for prop in prop_container.get_children():
			if prop.has_signal("opened"):
				prop.opened.connect(_on_treasure_opened)

func _spawn_shop():
	# Shop room - no enemies, mark as cleared immediately so exit opens
	is_cleared = true
	_open_exit()

func _spawn_rest():
	# Rest room - heal player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.has_method("heal"):
			player.heal(50)
		elif player.get("current_health") != null:
			player.current_health = min(player.current_health + 50, player.max_health)
	# Rest room is safe - mark as cleared so exit opens
	is_cleared = true
	_open_exit()

func _on_treasure_opened():
	# Treasure collected - open exit
	_open_exit()

func _on_enemy_died(enemy: Node):
	if enemy in tracked_enemies:
		tracked_enemies.erase(enemy)
		enemies_alive -= 1
		if enemies_alive <= 0:
			all_enemies_dead.emit()
			if room_type == RoomType.BOSS:
				# Boss defeated - victory!
				await get_tree().create_timer(2.0).timeout
				EventBus.game_over.emit(true)
			else:
				_open_exit()
				if room_type == RoomType.COMBAT or room_type == RoomType.ELITE:
					_show_reward()

func _show_reward():
	var rewards = _generate_rewards()
	EventBus.show_reward_panel.emit(rewards)

func _generate_rewards() -> Array:
	var rewards = []
	var upgrade_manager = get_node_or_null("/root/UpgradeManager")
	if upgrade_manager:
		rewards = upgrade_manager.get_random_upgrades(3)
	return rewards

func _on_exit_body_entered(body: Node2D):
	if body.is_in_group("player") and is_cleared:
		EventBus.room_cleared.emit()
