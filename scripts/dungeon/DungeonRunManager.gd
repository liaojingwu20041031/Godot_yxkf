extends Node

signal room_completed
signal dungeon_completed

enum RoomType { START, COMBAT, ELITE, TREASURE, SHOP, REST, BOSS }

var room_sequence: Array = []
var current_room_index: int = 0
var total_rooms: int = 8

var room_scenes: Dictionary = {
	RoomType.START: "res://scenes/rooms/StartRoom.tscn",
	RoomType.COMBAT: "res://scenes/rooms/CombatRoom.tscn",
	RoomType.ELITE: "res://scenes/rooms/EliteRoom.tscn",
	RoomType.TREASURE: "res://scenes/rooms/TreasureRoom.tscn",
	RoomType.SHOP: "res://scenes/rooms/ShopRoom.tscn",
	RoomType.REST: "res://scenes/rooms/RestRoom.tscn",
	RoomType.BOSS: "res://scenes/rooms/BossRoom.tscn"
}

func _ready():
	_generate_room_sequence()

func _generate_room_sequence():
	room_sequence = [RoomType.START]
	var combat_rooms = 3
	var elite_rooms = 1
	var treasure_rooms = 1
	var shop_rooms = 1
	var rest_rooms = 1

	var middle_rooms = []
	for i in range(combat_rooms):
		middle_rooms.append(RoomType.COMBAT)
	for i in range(elite_rooms):
		middle_rooms.append(RoomType.ELITE)
	for i in range(treasure_rooms):
		middle_rooms.append(RoomType.TREASURE)
	for i in range(shop_rooms):
		middle_rooms.append(RoomType.SHOP)
	for i in range(rest_rooms):
		middle_rooms.append(RoomType.REST)

	middle_rooms.shuffle()
	room_sequence.append_array(middle_rooms)
	room_sequence.append(RoomType.BOSS)

func get_current_room_type() -> RoomType:
	if current_room_index < room_sequence.size():
		return room_sequence[current_room_index]
	return RoomType.COMBAT

func get_current_room_scene() -> String:
	var room_type = get_current_room_type()
	return room_scenes.get(room_type, room_scenes[RoomType.COMBAT])

func advance_to_next_room():
	current_room_index += 1
	if current_room_index >= room_sequence.size():
		dungeon_completed.emit()
	else:
		room_completed.emit()
		load_current_room()

func load_current_room():
	var scene_path = get_current_room_scene()
	get_tree().change_scene_to_file(scene_path)

func start_new_run():
	current_room_index = 0
	_generate_room_sequence()
	load_current_room()

func get_room_progress() -> Dictionary:
	return {
		"current": current_room_index + 1,
		"total": room_sequence.size(),
		"room_type": RoomType.keys()[get_current_room_type()]
	}
