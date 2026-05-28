extends Node2D

var current_room: Node2D = null
var player: CharacterBody2D = null
var camera: Camera2D = null
var room_index: int = 0

var room_sequence: Array[String] = [
	"res://scenes/rooms/StartRoom.tscn",
	"res://scenes/rooms/CombatRoom.tscn",
	"res://scenes/rooms/EliteRoom.tscn",
	"res://scenes/rooms/TreasureRoom.tscn",
	"res://scenes/rooms/CombatRoom.tscn",
	"res://scenes/rooms/ShopRoom.tscn",
	"res://scenes/rooms/RestRoom.tscn",
	"res://scenes/rooms/BossRoom.tscn",
]

func _ready():
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.game_over.connect(_on_game_over)
	camera = $Camera2D
	_load_room(0)

func _load_room(index: int):
	if index >= room_sequence.size():
		EventBus.game_over.emit(true)
		return

	room_index = index

	# Remove old room
	if current_room:
		current_room.queue_free()
		current_room = null
		player = null

	# Load new room scene
	var scene_path = room_sequence[index]
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
	var room_types = ["START", "COMBAT", "ELITE", "TREASURE", "COMBAT", "SHOP", "REST", "BOSS"]
	if index < room_types.size():
		EventBus.room_entered.emit(room_types[index])

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
