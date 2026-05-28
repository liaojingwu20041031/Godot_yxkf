extends Node

const UPGRADE_DATA_PATH := "res://data/upgrades/upgrades.json"

var all_upgrades: Array = []
var applied_upgrades: Array = []
var regen_targets: Array = []
var room_clear_targets: Array = []

func _ready():
	_init_upgrades()
	set_process(false)
	if not EventBus.room_cleared.is_connected(_on_room_cleared):
		EventBus.room_cleared.connect(_on_room_cleared)

func _init_upgrades():
	if _load_upgrades_from_json():
		return

	all_upgrades = [
		{
			"id": "steel_body",
			"name": "钢铁之躯",
			"description": "最大生命 +20",
			"rarity": "common",
			"icon": "heart",
			"effect": {"type": "stat", "stat": "max_health", "value": 20}
		},
		{
			"id": "sharp_blade",
			"name": "锋利剑刃",
			"description": "攻击力 +3",
			"rarity": "common",
			"icon": "sword",
			"effect": {"type": "stat", "stat": "attack_power", "value": 3}
		},
		{
			"id": "light_feet",
			"name": "轻盈脚步",
			"description": "移动速度 +10%",
			"rarity": "common",
			"icon": "boot",
			"effect": {"type": "stat_percent", "stat": "move_speed", "value": 0.1}
		},
		{
			"id": "shadow_step",
			"name": "暗影步",
			"description": "冲刺期间无敌",
			"rarity": "rare",
			"icon": "shadow",
			"effect": {"type": "ability", "ability": "dash_invulnerable"}
		},
		{
			"id": "roll_master",
			"name": "翻滚大师",
			"description": "翻滚冷却 -20%",
			"rarity": "rare",
			"icon": "dodge",
			"effect": {"type": "stat_percent", "stat": "roll_cooldown", "value": -0.2}
		},
		{
			"id": "backstab",
			"name": "背刺时刻",
			"description": "翻滚后下一击暴击",
			"rarity": "rare",
			"icon": "crit",
			"effect": {"type": "ability", "ability": "roll_crit"}
		},
		{
			"id": "double_jump",
			"name": "二段跳",
			"description": "空中可再次跳跃",
			"rarity": "epic",
			"icon": "wing",
			"effect": {"type": "ability", "ability": "double_jump"}
		},
		{
			"id": "air_slash",
			"name": "空中斩击",
			"description": "空中攻击伤害 +30%",
			"rarity": "rare",
			"icon": "sword_air",
			"effect": {"type": "ability", "ability": "air_attack_boost"}
		},
		{
			"id": "fire_sword",
			"name": "火焰剑",
			"description": "攻击附带燃烧",
			"rarity": "epic",
			"icon": "fire",
			"effect": {"type": "element", "element": "fire", "chance": 0.25}
		},
		{
			"id": "poison_blade",
			"name": "毒刃",
			"description": "攻击附带中毒",
			"rarity": "rare",
			"icon": "poison",
			"effect": {"type": "element", "element": "poison", "chance": 0.3}
		},
		{
			"id": "lifesteal",
			"name": "吸血符文",
			"description": "击杀回复 5 生命",
			"rarity": "rare",
			"icon": "vampire",
			"effect": {"type": "on_kill", "stat": "health", "value": 5}
		},
		{
			"id": "berserker",
			"name": "狂战士",
			"description": "生命低于 30% 时伤害 +50%",
			"rarity": "epic",
			"icon": "rage",
			"effect": {"type": "conditional", "condition": "low_health", "threshold": 0.3, "stat": "attack_power", "multiplier": 1.5}
		},
		{
			"id": "glass_cannon",
			"name": "玻璃剑",
			"description": "伤害 +40%，受到伤害 +25%",
			"rarity": "cursed",
			"icon": "glass",
			"effect": {"type": "tradeoff", "bonus": {"stat": "attack_power", "multiplier": 1.4}, "penalty": {"stat": "defense", "multiplier": 0.75}}
		}
	]

func _load_upgrades_from_json() -> bool:
	if not FileAccess.file_exists(UPGRADE_DATA_PATH):
		return false

	var file = FileAccess.open(UPGRADE_DATA_PATH, FileAccess.READ)
	if not file:
		return false

	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return false
	if not (parsed.get("upgrades", []) is Array):
		return false

	all_upgrades = parsed["upgrades"]
	return all_upgrades.size() > 0

func get_random_upgrades(count: int) -> Array:
	var available = all_upgrades.duplicate()
	available.shuffle()
	var selected = []
	for i in range(min(count, available.size())):
		selected.append(available[i])
	return selected

func apply_upgrade(player: Node, upgrade_id: String):
	var upgrade_data = null
	for upgrade in all_upgrades:
		if upgrade["id"] == upgrade_id:
			upgrade_data = upgrade
			break

	if not upgrade_data:
		return

	applied_upgrades.append(upgrade_data)
	var effect = upgrade_data["effect"]

	match effect["type"]:
		"stat":
			_apply_stat(player, effect["stat"], effect["value"])
		"stat_percent":
			_apply_stat_percent(player, effect["stat"], effect["value"])
		"ability":
			_apply_ability(player, effect["ability"])
		"element":
			_apply_element(player, effect["element"], effect.get("chance", 1.0))
		"on_kill":
			_apply_on_kill(player, effect["stat"], effect["value"])
		"compound":
			_apply_compound(player, effect.get("effects", []))
		"regen":
			_apply_regen(player, effect.get("stat", "health"), effect.get("value", 0.0))
		"on_room_clear":
			_apply_on_room_clear(player, effect.get("stat", "health"), effect.get("value", 0))
		"conditional":
			_apply_conditional(player, effect)
		"tradeoff":
			_apply_tradeoff(player, effect)

	EventBus.upgrade_selected.emit(upgrade_id)

func _apply_stat(player: Node, stat: String, value: int):
	match stat:
		"max_health":
			player.max_health += value
			player.current_health += value
			EventBus.player_health_changed.emit(player.current_health, player.max_health)
		"attack_power":
			player.attack_power += value
		"defense":
			player.defense += value
		"shield":
			if player.has_method("add_shield"):
				player.add_shield(value)

func _apply_stat_percent(player: Node, stat: String, value: float):
	match stat:
		"move_speed":
			# Store speed multiplier as metadata since MOVE_SPEED is a constant
			var current_mult = player.get_meta("speed_multiplier", 1.0)
			player.set_meta("speed_multiplier", current_mult * (1.0 + value))
		"roll_cooldown":
			var current_mult = player.get_meta("roll_cooldown_multiplier", 1.0)
			player.set_meta("roll_cooldown_multiplier", current_mult * (1.0 + value))
		"attack_speed":
			var current_mult = player.get_meta("attack_speed_multiplier", 1.0)
			player.set_meta("attack_speed_multiplier", current_mult * (1.0 + value))
		"gold_multiplier":
			var current_gold_mult = player.get_meta("gold_multiplier", 1.0)
			player.set_meta("gold_multiplier", current_gold_mult * (1.0 + value))

func _apply_ability(player: Node, ability: String):
	match ability:
		"double_jump":
			player.can_double_jump = true
		"dash_invulnerable":
			player.set_meta("dash_invulnerable", true)
		"roll_crit":
			player.set_meta("roll_crit", true)
		"air_attack_boost":
			player.set_meta("air_attack_boost", true)

func _apply_element(player: Node, element: String, chance: float):
	player.set_meta("element_" + element, true)
	player.set_meta("element_" + element + "_chance", chance)

func _apply_on_kill(player: Node, stat: String, value: int):
	player.set_meta("on_kill_" + stat, value)

func _apply_compound(player: Node, effects: Array):
	for effect in effects:
		if effect is Dictionary:
			_apply_effect(player, effect)

func _apply_effect(player: Node, effect: Dictionary):
	match effect.get("type", ""):
		"stat":
			_apply_stat(player, effect.get("stat", ""), effect.get("value", 0))
		"stat_percent":
			_apply_stat_percent(player, effect.get("stat", ""), effect.get("value", 0.0))
		"ability":
			_apply_ability(player, effect.get("ability", ""))
		"element":
			_apply_element(player, effect.get("element", ""), effect.get("chance", 1.0))
		"on_kill":
			_apply_on_kill(player, effect.get("stat", ""), effect.get("value", 0))
		"regen":
			_apply_regen(player, effect.get("stat", "health"), effect.get("value", 0.0))
		"on_room_clear":
			_apply_on_room_clear(player, effect.get("stat", "health"), effect.get("value", 0))
		"conditional":
			_apply_conditional(player, effect)
		"tradeoff":
			_apply_tradeoff(player, effect)

func _apply_regen(player: Node, stat: String, value: float):
	if stat != "health" or value <= 0.0:
		return

	for target in regen_targets:
		if target.get("player") == player:
			target["health_per_second"] = target.get("health_per_second", 0.0) + value
			set_process(true)
			return

	regen_targets.append({"player": player, "health_per_second": value, "carry": 0.0})
	set_process(true)

func _apply_on_room_clear(player: Node, stat: String, value: int):
	for target in room_clear_targets:
		if target.get("player") == player and target.get("stat", "") == stat:
			target["value"] = target.get("value", 0) + value
			return
	room_clear_targets.append({"player": player, "stat": stat, "value": value})

func _apply_conditional(player: Node, effect: Dictionary):
	var condition = effect.get("condition", "")
	if condition == "low_health":
		player.set_meta("conditional_low_health_stat", effect.get("stat", ""))
		player.set_meta("conditional_low_health_threshold", effect.get("threshold", 0.3))
		player.set_meta("conditional_low_health_multiplier", effect.get("multiplier", 1.0))

func _apply_tradeoff(player: Node, effect: Dictionary):
	var bonus = effect.get("bonus", {})
	var penalty = effect.get("penalty", {})
	if bonus is Dictionary:
		_apply_multiplier(player, bonus.get("stat", ""), bonus.get("multiplier", 1.0))
	if penalty is Dictionary:
		_apply_multiplier(player, penalty.get("stat", ""), penalty.get("multiplier", 1.0))

func _apply_multiplier(player: Node, stat: String, multiplier: float):
	match stat:
		"attack_power":
			player.attack_power = max(1, int(round(player.attack_power * multiplier)))
		"defense":
			player.defense = max(0, int(round(player.defense * multiplier)))
		"max_health":
			var old_max = player.max_health
			player.max_health = max(1, int(round(player.max_health * multiplier)))
			player.current_health = clamp(player.current_health + player.max_health - old_max, 1, player.max_health)
			EventBus.player_health_changed.emit(player.current_health, player.max_health)

func _process(delta: float):
	for i in range(regen_targets.size() - 1, -1, -1):
		var target = regen_targets[i]
		var player = target.get("player")
		if not is_instance_valid(player):
			regen_targets.remove_at(i)
			continue
		target["carry"] = target.get("carry", 0.0) + target.get("health_per_second", 0.0) * delta
		var heal_amount = int(floor(target["carry"]))
		if heal_amount > 0:
			target["carry"] -= heal_amount
			if player.has_method("heal"):
				player.heal(heal_amount)

	if regen_targets.is_empty():
		set_process(false)

func _on_room_cleared():
	for i in range(room_clear_targets.size() - 1, -1, -1):
		var target = room_clear_targets[i]
		var player = target.get("player")
		if not is_instance_valid(player):
			room_clear_targets.remove_at(i)
			continue
		match target.get("stat", ""):
			"health":
				if player.has_method("heal"):
					player.heal(target.get("value", 0))
			"shield":
				if player.has_method("add_shield"):
					player.add_shield(target.get("value", 0))
