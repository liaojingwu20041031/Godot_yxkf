extends Node

const SAVE_PATH = "user://save_game.json"

func save_game(data: Dictionary):
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		file.close()
		return json.data
	return {}

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func get_save_data() -> Dictionary:
	return {
		"player": {
			"health": 100,
			"max_health": 100,
			"attack": 10,
			"defense": 0
		},
		"inventory": [],
		"equipment": {},
		"gold": GameManager.gold,
		"keys": GameManager.keys,
		"room_index": GameManager.current_room_index,
		"upgrades": []
	}
