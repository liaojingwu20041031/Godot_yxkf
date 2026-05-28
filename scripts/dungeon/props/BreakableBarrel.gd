extends Node2D

@export var health: int = 1
@export var gold_drop: int = 5

var _dead: bool = false

@onready var hurtbox: Area2D = $BarrelHurtbox
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	hurtbox.area_entered.connect(_on_area_entered)
	add_to_group("breakables")

func _on_area_entered(area: Area2D):
	if _dead:
		return
	# Check if the area is a player attack hitbox
	if area.has_method("set_damage") or area.get("damage") != null:
		var dmg = area.get("damage") if area.get("damage") != null else 10
		take_damage(dmg)

func take_damage(amount: int):
	if _dead:
		return
	health -= amount
	if health <= 0:
		_die()
	else:
		# Hit flash
		if sprite:
			var tween = create_tween()
			sprite.modulate = Color(2, 0.5, 0.5, 1)
			tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.15)

func _die():
	_dead = true
	# Drop gold
	if gold_drop > 0:
		GameManager.add_gold(gold_drop)
	# Brief visual then remove
	if sprite:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
		tween.tween_callback(queue_free)
	else:
		queue_free()
