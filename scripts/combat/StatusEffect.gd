extends RefCounted

enum EffectType { BURN, POISON, FREEZE, SLOW, BLEED, VULNERABLE, WEAKEN, SHIELD, BERSERK, CURSE }

var effect_type: EffectType
var duration: float
var power: float
var tick_timer: float = 0.0
var tick_interval: float = 1.0

func _init(type: EffectType, dur: float, pow: float):
	effect_type = type
	duration = dur
	power = pow

func tick(delta: float) -> Dictionary:
	duration -= delta
	tick_timer += delta
	var result = {"damage": 0, "heal": 0}

	if tick_timer >= tick_interval:
		tick_timer -= tick_interval
		match effect_type:
			EffectType.BURN:
				result["damage"] = int(power)
			EffectType.POISON:
				result["damage"] = int(power)
			EffectType.BLEED:
				result["damage"] = int(power * 0.5)
			EffectType.SHIELD:
				result["heal"] = 0
			_:
				pass

	return result

func is_expired() -> bool:
	return duration <= 0

func get_name() -> String:
	match effect_type:
		EffectType.BURN:
			return "燃烧"
		EffectType.POISON:
			return "中毒"
		EffectType.FREEZE:
			return "冰冻"
		EffectType.SLOW:
			return "减速"
		EffectType.BLEED:
			return "流血"
		EffectType.VULNERABLE:
			return "易伤"
		EffectType.WEAKEN:
			return "虚弱"
		EffectType.SHIELD:
			return "护盾"
		EffectType.BERSERK:
			return "狂暴"
		EffectType.CURSE:
			return "诅咒"
	return "未知"
