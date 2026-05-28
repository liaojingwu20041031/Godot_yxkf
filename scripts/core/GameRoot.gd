extends Node2D

var current_room: Node2D = null
var player: CharacterBody2D = null
var camera: Camera2D = null
var run_depth: int = 0
var max_depth: int = 8

# Room pool: type -> array of scene paths
var room_pools: Dictionary = {
	"START": ["res://scenes/rooms/StartRoom.tscn"],
	"COMBAT": [
		"res://scenes/rooms/CombatRoom_Flat.tscn",
		"res://scenes/rooms/CombatRoom_Platform.tscn",
		"res://scenes/rooms/CombatRoom_Pit.tscn",
		"res://scenes/rooms/CombatRoom_Vertical.tscn",
		"res://scenes/rooms/CombatRoom_Wide.tscn",
		"res://scenes/rooms/TrapRoom.tscn",
	],
	"ELITE": [
		"res://scenes/rooms/CombatRoom_Platform.tscn",
		"res://scenes/rooms/CombatRoom_Pit.tscn",
		"res://scenes/rooms/CombatRoom_Vertical.tscn",
	],
	"TREASURE": [
		"res://scenes/rooms/TreasureRoom.tscn",
		"res://scenes/rooms/LockedTreasureRoom.tscn",
	],
	"SHOP": ["res://scenes/rooms/ShopRoom.tscn"],
	"REST": ["res://scenes/rooms/RestRoom.tscn"],
	"SHRINE": ["res://scenes/rooms/ShrineRoom.tscn"],
	"BOSS": ["res://scenes/rooms/BossRoom.tscn"],
}

# Route options by depth: what room types are available at each depth
var route_table: Dictionary = {
	0: ["START"],
	1: ["COMBAT", "TREASURE"],
	2: ["COMBAT", "SHRINE"],
	3: ["ELITE", "SHOP"],
	4: ["REST", "TREASURE"],
	5: ["COMBAT", "ELITE"],
	6: ["REST"],
	7: ["BOSS"],
}

var _last_picked: Dictionary = {}

func _ready():
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.room_exit_selected.connect(_on_room_exit_selected)
	EventBus.game_over.connect(_on_game_over)
	camera = $Camera2D
	player = $Player
	_load_room_at_depth(0)

func _pick_room_scene(room_type: String) -> String:
	var pool = room_pools.get(room_type, [])
	if pool.is_empty():
		push_error("No rooms in pool for type: " + room_type)
		return ""
	if pool.size() == 1:
		return pool[0]
	var pick = pool[randi() % pool.size()]
	var attempts = 0
	while pick == _last_picked.get(room_type, "") and attempts < 10:
		pick = pool[randi() % pool.size()]
		attempts += 1
	_last_picked[room_type] = pick
	return pick

func get_available_routes() -> Array[String]:
	var routes: Array[String] = []
	if route_table.has(run_depth + 1):
		for r in route_table[run_depth + 1]:
			routes.append(r)
	if routes.is_empty():
		# Default fallback
		routes.append("COMBAT")
	return routes

func _load_room_by_type(room_type: String):
	run_depth += 1
	print("[GameRoot] Loading room: %s (depth=%d)" % [room_type, run_depth])
	if run_depth >= max_depth:
		EventBus.game_over.emit(true)
		return

	# Remove old room
	if current_room:
		current_room.queue_free()
		current_room = null

	var scene_path = _pick_room_scene(room_type)
	if scene_path.is_empty():
		push_error("Failed to pick room for type: " + room_type)
		return

	var scene = load(scene_path)
	if scene == null:
		push_error("Failed to load room: " + scene_path)
		return

	current_room = scene.instantiate()
	add_child(current_room)
	move_child(player, get_child_count() - 1)

	# Move player to spawn point
	var spawn = current_room.get_node_or_null("PlayerSpawnPoint")
	if spawn:
		player.global_position = spawn.global_position
	else:
		player.global_position = Vector2(160, 306)

	player.velocity = Vector2.ZERO

	if camera:
		camera.global_position = player.global_position
		camera.limit_left = 0
		camera.limit_top = 0
		camera.limit_right = 640
		camera.limit_bottom = 384

	GameManager.current_room_index = run_depth
	EventBus.room_entered.emit(room_type)
	print("[GameRoot] Room loaded: %s" % room_type)

func _load_room_at_depth(depth: int):
	run_depth = depth
	if route_table.has(depth):
		var options = route_table[depth]
		if options.size() == 1:
			_load_room_by_type(options[0])
		else:
			_load_room_by_type(options[0])
	else:
		EventBus.game_over.emit(true)

func _process(_delta):
	if player and is_instance_valid(player) and camera:
		camera.global_position = player.global_position

func _on_room_cleared():
	print("[GameRoot] room_cleared signal received")
	await get_tree().create_timer(1.5).timeout
	var routes = get_available_routes()
	print("[GameRoot] Available routes: %s" % str(routes))
	if routes.size() >= 1:
		_load_room_by_type(routes[0])

func _on_room_exit_selected(target_room_type: String):
	print("[GameRoot] room_exit_selected signal received: '%s'" % target_room_type)
	await get_tree().create_timer(1.0).timeout
	_load_room_by_type(target_room_type)

func _on_game_over(victory: bool):
	if victory:
		get_tree().change_scene_to_file("res://scenes/ui/Victory.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
