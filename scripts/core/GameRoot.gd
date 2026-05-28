extends Node2D

var current_room: Node2D = null
var player: CharacterBody2D = null
var camera: Camera2D = null
var room_index: int = 0

# Room pool: type -> array of scene paths
var room_pools: Dictionary = {
	"START": ["res://scenes/rooms/StartRoom.tscn"],
	"COMBAT": [
		"res://scenes/rooms/CombatRoom_Flat.tscn",
		"res://scenes/rooms/CombatRoom_Platform.tscn",
		"res://scenes/rooms/CombatRoom_Pit.tscn",
	],
	"TREASURE": ["res://scenes/rooms/TreasureRoom.tscn"],
	"SHOP": ["res://scenes/rooms/ShopRoom.tscn"],
	"REST": ["res://scenes/rooms/RestRoom.tscn"],
	"BOSS": ["res://scenes/rooms/BossRoom.tscn"],
}

# Sequence of room types for a run
var run_sequence: Array[String] = [
	"START", "COMBAT", "COMBAT", "TREASURE",
	"COMBAT", "SHOP", "REST", "BOSS"
]

var _last_picked: Dictionary = {}

func _ready():
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.game_over.connect(_on_game_over)
	camera = $Camera2D
	_load_room(0)

func _pick_room_scene(room_type: String) -> String:
	var pool = room_pools.get(room_type, [])
	if pool.is_empty():
		push_error("No rooms in pool for type: " + room_type)
		return ""
	if pool.size() == 1:
		return pool[0]
	var pick = pool[randi() % pool.size()]
	# Avoid picking the same room twice in a row
	var attempts = 0
	while pick == _last_picked.get(room_type, "") and attempts < 10:
		pick = pool[randi() % pool.size()]
		attempts += 1
	_last_picked[room_type] = pick
	return pick

func _load_room(index: int):
	if index >= run_sequence.size():
		EventBus.game_over.emit(true)
		return

	room_index = index

	# Remove old room
	if current_room:
		current_room.queue_free()
		current_room = null
		player = null

	# Pick random room from pool
	var room_type = run_sequence[index]
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

	# Find player in room
	_find_player()

	# Update GameManager
	GameManager.current_room_index = index
	EventBus.room_entered.emit(room_type)

func _find_player():
	# Find existing player in the room
	for child in current_room.get_children():
		if child.is_in_group("player"):
			player = child
			break
	if not player:
		# Search deeper
		player = current_room.get_node_or_null("Player")
	if player and camera:
		camera.global_position = player.global_position

func _process(_delta):
	# Camera follows player
	if player and is_instance_valid(player) and camera:
		camera.global_position = player.global_position

func _on_room_cleared():
	# Short delay then load next room
	await get_tree().create_timer(1.5).timeout
	_load_room(room_index + 1)

func _on_game_over(victory: bool):
	if victory:
		get_tree().change_scene_to_file("res://scenes/ui/Victory.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
