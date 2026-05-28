extends Area2D

@export var damage: int = 20
@export var safe_position: Vector2 = Vector2(320, 280)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		# Deal damage
		EventBus.player_hit.emit(damage, self)
		# Teleport to safe position
		body.global_position = safe_position
		body.velocity = Vector2.ZERO
