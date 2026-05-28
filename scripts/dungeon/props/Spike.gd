extends Node2D

@export var damage: int = 15
@export var damage_cooldown: float = 1.0

var _cooldown_timer: float = 0.0
var _player_in_zone: bool = false

@onready var damage_zone: Area2D = $DamageZone

func _ready():
	damage_zone.body_entered.connect(_on_body_entered)
	damage_zone.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		_player_in_zone = true
		_deal_damage(body)

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		_player_in_zone = false

func _process(delta):
	if _cooldown_timer > 0:
		_cooldown_timer -= delta

func _deal_damage(_player: Node):
	if _cooldown_timer > 0:
		return
	_cooldown_timer = damage_cooldown
	EventBus.player_hit.emit(damage, self)
