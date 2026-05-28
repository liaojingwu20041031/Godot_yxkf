extends Interactable

@export var item_name: String = "药水"
@export var item_cost: int = 30
@export var item_type: String = "consumable"  # consumable, key, equipment
@export var item_value: int = 50  # heal amount or key count
@export var item_texture: String = ""

var _purchased: bool = false

func _ready():
	prompt_text = "按 E 购买 %s (%d金)" % [item_name, item_cost]
	one_time_use = true
	super._ready()

func can_interact() -> bool:
	return not _purchased

func interact(player: Node):
	if GameManager.gold >= item_cost:
		GameManager.add_gold(-item_cost)
		_purchased = true
		_give_item(player)
		show_floating_text("购买成功!", Color(0.3, 1, 0.3))
		flash_visual(Color(1, 1, 2, 1), 0.5)
	else:
		show_floating_text("金币不足!", Color(1, 0.3, 0.3))
		flash_visual(Color(1, 0.3, 0.3, 1), 0.3)

func _give_item(player: Node):
	match item_type:
		"consumable":
			if player.has_method("heal"):
				player.heal(item_value)
				show_floating_text("+%d HP" % item_value, Color(0.3, 1, 0.3))
		"key":
			GameManager.add_key(item_value)
			show_floating_text("+%d 钥匙" % item_value, Color(0.3, 0.8, 1.0))
		"equipment":
			var item_data = {
				"type": "equipment",
				"name": item_name,
				"description": "从商店购买",
				"rarity": "common",
				"texture": item_texture,
			}
			EventBus.item_picked_up.emit(item_data)
