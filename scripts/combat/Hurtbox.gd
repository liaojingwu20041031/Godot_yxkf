extends Area2D

signal hurt(damage: int, knockback: Vector2, source: Node)

@export var max_health: int = 100
@export var defense: int = 0
var current_health: int
var invulnerable: bool = false

func _ready():
	current_health = max_health

func take_damage(damage: int, knockback: Vector2 = Vector2.ZERO, source: Node = null):
	if invulnerable:
		return
	var actual_damage = max(0, damage - defense)
	current_health -= actual_damage
	hurt.emit(actual_damage, knockback, source)
	if current_health <= 0:
		if get_parent().has_method("die"):
			get_parent().die()

func heal(amount: int):
	current_health = min(current_health + amount, max_health)

func set_invulnerable(value: bool):
	invulnerable = value

func get_health_percent() -> float:
	return float(current_health) / float(max_health)
