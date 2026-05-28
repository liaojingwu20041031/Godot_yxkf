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
var enemies_total: int = 0
var is_cleared: bool = false
var is_active: bool = false
var tracked_enemies: Array[Node] = []

@onready var entrance_door: StaticBody2D = get_node_or_null("EntranceDoor")
@onready var exit_door: StaticBody2D = get_node_or_null("ExitDoor")
@onready var enemy_container: Node2D = get_node_or_null("EnemyContainer")
@onready var reward_point: Marker2D = get_node_or_null("RewardPoint")

func _ready():
	_setup_tilemap()

	# Create exit detection area directly on the room (not on the door)
	_create_exit_detection()

	EventBus.enemy_died.connect(_on_enemy_died)

	# Setup doors based on room type
	match room_type:
		RoomType.START:
			if entrance_door and entrance_door.has_method("open"):
				entrance_door.open()
			if exit_door and exit_door.has_method("open"):
				exit_door.open()
			is_cleared = true
		RoomType.COMBAT, RoomType.ELITE, RoomType.BOSS:
			if entrance_door and entrance_door.has_method("open"):
				entrance_door.open()
			if exit_door and exit_door.has_method("close"):
				exit_door.close()
			call_deferred("activate")
		RoomType.TREASURE:
			if entrance_door and entrance_door.has_method("open"):
				entrance_door.open()
			if exit_door and exit_door.has_method("close"):
				exit_door.close()
			call_deferred("activate")
		RoomType.SHOP, RoomType.REST:
			if entrance_door and entrance_door.has_method("open"):
				entrance_door.open()
			if exit_door and exit_door.has_method("open"):
				exit_door.open()
			call_deferred("activate")
		_:
			if entrance_door and entrance_door.has_method("open"):
				entrance_door.open()
			if exit_door and exit_door.has_method("open"):
				exit_door.open()
			is_cleared = true

func _create_exit_detection():
	# Create a dedicated exit detection area at the exit door position
	var exit_pos = Vector2(600, 296)
	if exit_door:
		exit_pos = exit_door.global_position

	var exit_area = Area2D.new()
	exit_area.name = "ExitArea"
	exit_area.collision_layer = 0
	exit_area.collision_mask = 1  # Detect player (layer 1)
	exit_area.position = exit_pos

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(32, 64)  # Larger detection area
	shape.shape = rect
	exit_area.add_child(shape)

	add_child(exit_area)
	exit_area.body_entered.connect(_on_exit_body_entered)

func _setup_tilemap():
	if has_node("DungeonTileMap"):
		return
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
	if entrance_door and entrance_door.has_method("close"):
		entrance_door.close()

func _unlock_exit():
	if exit_door and exit_door.has_method("open"):
		exit_door.open()
	is_cleared = true
	EventBus.show_room_message.emit("出口已开启 - 走到门口进入下一房间")

func _complete_room():
	EventBus.room_cleared.emit()

func _spawn_enemies():
	enemies_alive = 0
	enemies_total = 0
	tracked_enemies.clear()
	if enemy_container:
		for child in enemy_container.get_children():
			if child.is_in_group("enemies"):
				enemies_alive += 1
				tracked_enemies.append(child)
	for i in range(enemies_to_spawn.size()):
		var enemy_scene = enemies_to_spawn[i]
		var spawn_pos = spawn_points[i] if i < spawn_points.size() else Vector2(randf_range(50, 250), 100)
		var enemy = enemy_scene.instantiate()
		enemy.position = spawn_pos
		enemy_container.add_child(enemy)
		enemies_alive += 1
		tracked_enemies.append(enemy)
	enemies_total = enemies_alive
	EventBus.show_room_message.emit("击败所有敌人 0/%d" % enemies_total)
	for enemy in tracked_enemies:
		print("[Room] Enemy: %s pos=%s" % [enemy.name, enemy.global_position])
	if enemies_total <= 0 and (room_type == RoomType.COMBAT or room_type == RoomType.ELITE):
		push_warning("Combat room has no enemies, unlocking exit")
		_unlock_exit()

func _spawn_treasure():
	var prop_container = get_node_or_null("PropContainer")
	if prop_container:
		for prop in prop_container.get_children():
			if prop.has_signal("opened"):
				prop.opened.connect(_on_treasure_opened)

func _spawn_shop():
	pass

func _spawn_rest():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("heal"):
		player.heal(50)

func _on_treasure_opened():
	_unlock_exit()

func _on_enemy_died(enemy: Node):
	if enemy in tracked_enemies:
		tracked_enemies.erase(enemy)
		enemies_alive -= 1
		var killed = enemies_total - enemies_alive
		if enemies_alive <= 0:
			all_enemies_dead.emit()
			if room_type == RoomType.BOSS:
				_unlock_exit()
				await get_tree().create_timer(2.0).timeout
				EventBus.game_over.emit(true)
			else:
				_unlock_exit()
				if room_type == RoomType.COMBAT or room_type == RoomType.ELITE:
					_show_reward()
		else:
			EventBus.show_room_message.emit("击败所有敌人 %d/%d" % [killed, enemies_total])

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
	print("[Room] Exit body_entered: %s is_player=%s is_cleared=%s" % [body.name, body.is_in_group("player"), is_cleared])
	if body.is_in_group("player") and is_cleared:
		_complete_room()
