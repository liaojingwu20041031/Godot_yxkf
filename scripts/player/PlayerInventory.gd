extends Node

signal item_equipped(slot: String, item: Dictionary)
signal item_unequipped(slot: String)
signal item_used(item: Dictionary)
signal inventory_changed

var equipment_slots: Dictionary = {
	"weapon": null,
	"armor": null,
	"amulet": null,
	"ring1": null,
	"ring2": null,
	"rune": null,
	"potion": null
}

var inventory: Array = []
var max_inventory_size: int = 20

func add_item(item: Dictionary) -> bool:
	if inventory.size() >= max_inventory_size:
		return false
	inventory.append(item)
	inventory_changed.emit()
	return true

func remove_item(index: int) -> Dictionary:
	if index < 0 or index >= inventory.size():
		return {}
	var item = inventory[index]
	inventory.remove_at(index)
	inventory_changed.emit()
	return item

func equip_item(index: int) -> bool:
	if index < 0 or index >= inventory.size():
		return false

	var item = inventory[index]
	var slot = item.get("slot", "")
	if slot == "" or not equipment_slots.has(slot):
		return false

	if equipment_slots[slot]:
		unequip_item(slot)

	equipment_slots[slot] = item
	inventory.remove_at(index)
	inventory_changed.emit()
	item_equipped.emit(slot, item)
	return true

func unequip_item(slot: String) -> bool:
	if not equipment_slots.has(slot) or equipment_slots[slot] == null:
		return false

	var item = equipment_slots[slot]
	equipment_slots[slot] = null
	inventory.append(item)
	inventory_changed.emit()
	item_unequipped.emit(slot)
	return true

func use_potion(player: Node) -> bool:
	var potion_slot = equipment_slots.get("potion")
	if potion_slot == null:
		return false

	var heal_amount = potion_slot.get("heal", 0)
	var shield_amount = potion_slot.get("shield", 0)

	if heal_amount > 0:
		player.heal(heal_amount)
	if shield_amount > 0:
		player.add_shield(shield_amount)

	equipment_slots["potion"] = null
	inventory_changed.emit()
	item_used.emit(potion_slot)
	return true

func get_equipment_stats() -> Dictionary:
	var total_stats = {
		"attack": 0,
		"defense": 0,
		"max_health": 0,
		"move_speed": 0,
		"crit_chance": 0.0
	}

	for slot in equipment_slots:
		var item = equipment_slots[slot]
		if item:
			for stat in item.get("stats", {}):
				if total_stats.has(stat):
					total_stats[stat] += item["stats"][stat]

	return total_stats

func get_item_tooltip(index: int) -> String:
	if index < 0 or index >= inventory.size():
		return ""
	var item = inventory[index]
	var tooltip = item.get("name", "未知物品") + "\n"
	tooltip += item.get("type", "") + "\n"
	tooltip += item.get("description", "") + "\n"
	for stat in item.get("stats", {}):
		tooltip += stat + ": +" + str(item["stats"][stat]) + "\n"
	return tooltip
