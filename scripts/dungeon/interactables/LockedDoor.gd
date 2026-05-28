extends Interactable

@export var keys_required: int = 1
@export var target_room_type: String = "TREASURE"

var _is_unlocked: bool = false

func _ready():
	prompt_text = "按 E 使用钥匙开门 (%d把)" % keys_required
	one_time_use = true
	super._ready()

func can_interact() -> bool:
	return not _is_unlocked

func interact(player: Node):
	if GameManager.keys >= keys_required:
		GameManager.add_key(-keys_required)
		_is_unlocked = true
		show_floating_text("门已开启!", Color(0.3, 1, 0.3))
		flash_visual(Color(1, 1, 2, 1), 0.5)
		# Emit exit signal
		EventBus.room_exit_selected.emit(target_room_type)
	else:
		show_floating_text("需要 %d 把钥匙!" % keys_required, Color(1, 0.3, 0.3))
		flash_visual(Color(1, 0.3, 0.3, 1), 0.3)
