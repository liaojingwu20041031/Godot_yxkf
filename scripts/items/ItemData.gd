extends Resource

enum ItemType { WEAPON, ARMOR, AMULET, RING, RUNE, POTION, CONSUMABLE }
enum ItemRarity { COMMON, RARE, EPIC, LEGENDARY, CURSED }

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var item_type: ItemType = ItemType.WEAPON
@export var rarity: ItemRarity = ItemRarity.COMMON
@export var icon: Texture2D
@export var price: int = 0
@export var stats: Dictionary = {}
@export var special_effects: Array = []

func get_rarity_color() -> Color:
	match rarity:
		ItemRarity.COMMON:
			return Color(0.8, 0.8, 0.8)
		ItemRarity.RARE:
			return Color(0.3, 0.5, 1.0)
		ItemRarity.EPIC:
			return Color(0.7, 0.3, 1.0)
		ItemRarity.LEGENDARY:
			return Color(1.0, 0.8, 0.2)
		ItemRarity.CURSED:
			return Color(0.8, 0.1, 0.1)
	return Color.WHITE

func get_type_string() -> String:
	match item_type:
		ItemType.WEAPON:
			return "武器"
		ItemType.ARMOR:
			return "护甲"
		ItemType.AMULET:
			return "护符"
		ItemType.RING:
			return "戒指"
		ItemType.RUNE:
			return "符文"
		ItemType.POTION:
			return "药水"
		ItemType.CONSUMABLE:
			return "消耗品"
	return "未知"
