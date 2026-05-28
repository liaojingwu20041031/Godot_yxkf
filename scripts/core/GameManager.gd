extends Node

enum GameState { MENU, PLAYING, PAUSED, REWARD, BOSS, GAME_OVER, VICTORY }

var current_state: GameState = GameState.MENU
var current_room_index: int = 0
var total_rooms: int = 8  # matches GameRoot.run_sequence.size()
var gold: int = 0
var keys: int = 0
var potions: int = 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func change_state(new_state: GameState):
	current_state = new_state

func add_gold(amount: int):
	gold += amount
	EventBus.gold_changed.emit(gold)

func add_key(amount: int):
	keys += amount
	EventBus.key_changed.emit(keys)

func start_game():
	current_state = GameState.PLAYING
	current_room_index = 0
	gold = 0
	keys = 0
	get_tree().change_scene_to_file("res://scenes/core/GameRoot.tscn")

func restart_game():
	start_game()

func go_to_main_menu():
	current_state = GameState.MENU
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func quit_game():
	get_tree().quit()
