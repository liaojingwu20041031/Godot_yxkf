extends RefCounted

var damage: int
var knockback: Vector2
var source: Node
var element: String = ""
var status_effects: Array = []

func _init(p_damage: int = 0, p_knockback: Vector2 = Vector2.ZERO, p_source: Node = null):
	damage = p_damage
	knockback = p_knockback
	source = p_source

func add_element(element_name: String):
	element = element_name

func add_status_effect(effect_name: String, duration: float, power: float):
	status_effects.append({
		"name": effect_name,
		"duration": duration,
		"power": power
	})
