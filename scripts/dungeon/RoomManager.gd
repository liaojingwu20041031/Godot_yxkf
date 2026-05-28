extends Node2D

signal room_cleared
signal all_enemies_dead

enum RoomType { START, COMBAT, ELITE, TREASURE, SHOP, REST, SHRINE, BOSS }

@export var room_type: RoomType = RoomType.COMBAT
@export var enemies_to_spawn: Array[PackedScene] = []
@export var spawn_points: Array[Vector2] = []
@export var use_tilemap: bool = true

var enemies_alive: int = 0
var is_cleared: bool = false
var is_active: bool = false
var tracked_enemies: Array[Node] = []

@onready var entrance_door: StaticBody2D = get_node_or_null("EntranceDoor")
@onready var exit_door: StaticBody2D = get_node_or_null("ExitDoor")
@onready var enemy_container: Node2D = get_node_or_null("EnemyContainer")
@onready var reward_point: Marker2D = get_node_or_null("RewardPoint")

func _ready():
	# Setup TileMap if enabled
	if use_tilemap:
		_setup_tilemap()

	# Exit door starts closed
	if exit_door and exit_door.has_method("close"):
		exit_door.close()
	elif exit_door and exit_door.has_node("CollisionShape2D"):
		exit_door.get_node("CollisionShape2D").disabled = false

	# Entrance door starts open
	if entrance_door and entrance_door.has_method("open"):
		entrance_door.open()
	elif entrance_door and entrance_door.has_node("CollisionShape2D"):
		entrance_door.get_node("CollisionShape2D").disabled = true

	EventBus.enemy_died.connect(_on_enemy_died)

	if room_type == RoomType.COMBAT or room_type == RoomType.ELITE or room_type == RoomType.BOSS:
		call_deferred("activate")

func _setup_tilemap():
	if has_node("DungeonTileMap"):
		return
	var tilemap = TileMapLayer.new()
	tilemap.name = "DungeonTileMap"
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	tileset.add_physics_layer(0)
	tileset.set_physics_layer_collision_layer(0, 3)
	var floor_tex = load("res://assets/dungeon_crawl/floor/floor_sand_stone0.png")
	if floor_tex:
		var src = TileSetAtlasSource.new()
		src.texture = floor_tex
		src.texture_region_size = Vector2i(32, 32)
		src.create_tile(Vector2i(0, 0))
		tileset.add_source(src, 0)
	var wall_tex = load("res://assets/dungeon_crawl/wall/brick_brown0.png")
	if wall_tex:
		var src = TileSetAtlasSource.new()
		src.texture = wall_tex
		src.texture_region_size = Vector2i(32, 32)
		src.create_tile(Vector2i(0, 0))
		var td = src.get_tile_data(Vector2i(0, 0), 0)
		td.set_collision_polygons_count(0, 1)
		td.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(0,0), Vector2(32,0), Vector2(32,32), Vector2(0,32)]))
		tileset.add_source(src, 1)
	tilemap.tile_set = tileset
	for x in range(20):
		tilemap.set_cell(Vector2i(x, 11), 0, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(x, 10), 0, Vector2i(0, 0))
	for y in range(12):
		tilemap.set_cell(Vector2i(0, y), 1, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(19, y), 1, Vector2i(0, 0))
	for x in range(20):
		tilemap.set_cell(Vector2i(x, 0), 1, Vector2i(0, 0))
	add_child(tilemap)
	move_child(tilemap, 0)

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
		elif entrance_door.has_node("CollisionShape2D"):
			entrance_door.get_node("CollisionShape2D").disabled = false

func _open_exit():
	if exit_door:
		if exit_door.has_method("open"):
			exit_door.open()
		elif exit_door.has_node("CollisionShape2D"):
			exit_door.get_node("CollisionShape2D").disabled = true
	is_cleared = true
	room_cleared.emit()

func _open_entrance():
	if entrance_door:
		if entrance_door.has_method("open"):
			entrance_door.open()
		elif entrance_door.has_node("CollisionShape2D"):
			entrance_door.get_node("CollisionShape2D").disabled = true

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

func _on_enemy_died(enemy: Node):
	if enemy in tracked_enemies:
		tracked_enemies.erase(enemy)
		enemies_alive -= 1
		if enemies_alive <= 0:
			all_enemies_dead.emit()
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

func _spawn_treasure():
	pass

func _spawn_shop():
	pass

func _spawn_rest():
	pass

func _on_exit_body_entered(body: Node2D):
	if body.is_in_group("player") and is_cleared:
		EventBus.room_cleared.emit()
