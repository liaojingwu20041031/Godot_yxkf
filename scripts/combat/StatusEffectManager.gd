extends Node

var _status_script = load("res://scripts/combat/StatusEffect.gd")
var active_effects: Array = []

signal effect_applied(effect: RefCounted)
signal effect_removed(effect: RefCounted)
signal effect_ticked(effect: RefCounted, result: Dictionary)

enum EffectType { BURN, POISON, FREEZE, SLOW, BLEED, VULNERABLE, WEAKEN, SHIELD, BERSERK, CURSE }

func add_effect(type: EffectType, duration: float, power: float):
	for effect in active_effects:
		if effect.effect_type == type:
			effect.duration = max(effect.duration, duration)
			effect.power = max(effect.power, power)
			return

	var effect = _status_script.new(type, duration, power)
	active_effects.append(effect)
	effect_applied.emit(effect)

func _process(delta):
	var to_remove = []
	for effect in active_effects:
		var result = effect.tick(delta)
		if result["damage"] > 0 or result["heal"] > 0:
			effect_ticked.emit(effect, result)
		if effect.is_expired():
			to_remove.append(effect)

	for effect in to_remove:
		active_effects.erase(effect)
		effect_removed.emit(effect)

func has_effect(type: EffectType) -> bool:
	for effect in active_effects:
		if effect.effect_type == type:
			return true
	return false

func get_effect(type: EffectType):
	for effect in active_effects:
		if effect.effect_type == type:
			return effect
	return null

func remove_effect(type: EffectType):
	for effect in active_effects:
		if effect.effect_type == type:
			active_effects.erase(effect)
			effect_removed.emit(effect)
			return

func clear_all():
	active_effects.clear()
