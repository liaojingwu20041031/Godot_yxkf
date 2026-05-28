extends Node

var sprite: Sprite2D
var shader_material: ShaderMaterial
var flash_tween: Tween
var _flash_shader: Shader

func _init():
	pass

func setup(target_sprite: Sprite2D):
	sprite = target_sprite
	_flash_shader = load("res://scripts/shaders/hit_flash.gdshader")
	if _flash_shader and sprite:
		shader_material = ShaderMaterial.new()
		shader_material.shader = _flash_shader
		shader_material.set_shader_parameter("flash_intensity", 0.0)
		sprite.material = shader_material

func flash(duration: float = 0.1):
	if not shader_material or not sprite:
		return
	if flash_tween and flash_tween.is_valid():
		flash_tween.kill()
	flash_tween = sprite.create_tween()
	shader_material.set_shader_parameter("flash_intensity", 1.0)
	flash_tween.tween_method(_set_flash_intensity, 1.0, 0.0, duration)

func _set_flash_intensity(value: float):
	if shader_material:
		shader_material.set_shader_parameter("flash_intensity", value)
