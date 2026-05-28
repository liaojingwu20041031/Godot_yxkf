extends Area2D

var damage: int = 10
var knockback_dir: Vector2 = Vector2.ZERO
var knockback_force: float = 150.0
var owner_node: Node = null

func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		var kb = knockback_dir * knockback_force
		area.take_damage(damage, kb, owner_node)

func _on_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(damage, owner_node)

func set_damage(value: int):
	damage = value

func set_knockback(direction: Vector2, force: float):
	knockback_dir = direction
	knockback_force = force
