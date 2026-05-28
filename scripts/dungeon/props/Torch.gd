extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	if animated_sprite:
		animated_sprite.play("burn")
