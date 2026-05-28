extends Node

var all_upgrades: Array = []
var applied_upgrades: Array = []

func _ready():
	_init_upgrades()

func _init_upgrades():
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

func _apply_stat_percent(player: Node, stat: String, value: float):
	match stat:
		"move_speed":
			# Store speed multiplier as metadata since MOVE_SPEED is a constant
			var current_mult = player.get_meta("speed_multiplier", 1.0)
			player.set_meta("speed_multiplier", current_mult * (1.0 + value))
		"roll_cooldown":
			var current_mult = player.get_meta("roll_cooldown_multiplier", 1.0)
			player.set_meta("roll_cooldown_multiplier", current_mult * (1.0 + value))

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
