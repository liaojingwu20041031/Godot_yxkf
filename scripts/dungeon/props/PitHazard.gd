extends Area2D

@export var damage: int = 20
@export var safe_position: Vector2 = Vector2(320, 280)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage, self)
		else:
			EventBus.player_hit.emit(damage, self)
		body.global_position = safe_position
		if body is CharacterBody2D:
			body.velocity = Vector2.ZERO
