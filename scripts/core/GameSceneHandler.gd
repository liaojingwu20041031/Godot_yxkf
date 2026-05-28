extends Node

func _ready():
	EventBus.game_over.connect(_on_game_over)
	EventBus.room_cleared.connect(_on_room_cleared)

func _on_game_over(victory: bool):
	if victory:
		get_tree().change_scene_to_file("res://scenes/ui/Victory.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")

func _on_room_cleared():
	var run_manager = get_node_or_null("/root/DungeonRunManager")
	if run_manager:
		run_manager.advance_to_next_room()
