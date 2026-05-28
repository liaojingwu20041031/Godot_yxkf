extends Node

static func setup_sprite_frames(sprite: AnimatedSprite2D):
	var frames = SpriteFrames.new()

	var animations = {
		"idle": ["res://assets/free_knight/_Idle.png", 10, 8, true],
		"run": ["res://assets/free_knight/_Run.png", 10, 10, true],
		"jump": ["res://assets/free_knight/_Jump.png", 3, 8, false],
		"fall": ["res://assets/free_knight/_Fall.png", 3, 8, true],
		"attack": ["res://assets/free_knight/_Attack.png", 4, 10, false],
		"attack2": ["res://assets/free_knight/_Attack2.png", 6, 10, false],
		"attack_combo": ["res://assets/free_knight/_AttackCombo.png", 6, 12, false],
		"dash": ["res://assets/free_knight/_Dash.png", 2, 8, false],
		"roll": ["res://assets/free_knight/_Roll.png", 12, 12, false],
		"wall_slide": ["res://assets/free_knight/_WallSlide.png", 3, 8, true],
		"wall_climb": ["res://assets/free_knight/_WallClimb.png", 7, 8, true],
		"wall_hang": ["res://assets/free_knight/_WallHang.png", 1, 8, false],
		"crouch": ["res://assets/free_knight/_Crouch.png", 1, 8, false],
		"crouch_walk": ["res://assets/free_knight/_CrouchWalk.png", 8, 8, true],
		"crouch_attack": ["res://assets/free_knight/_CrouchAttack.png", 4, 10, false],
		"turn": ["res://assets/free_knight/_TurnAround.png", 3, 8, false],
		"slide": ["res://assets/free_knight/_Slide.png", 2, 8, false],
		"hit": ["res://assets/free_knight/_Hit.png", 1, 8, false],
		"death": ["res://assets/free_knight/_Death.png", 10, 8, false]
	}

	for anim_name in animations:
		var data = animations[anim_name]
		var texture_path = data[0]
		var frame_count = data[1]
		var fps = data[2]
		var loop = data[3]

		var texture = load(texture_path)
		if not texture:
			continue

		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, fps)
		frames.set_animation_loop(anim_name, loop)

		var frame_width = 120
		var frame_height = 80

		for i in range(frame_count):
			var atlas = AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(i * frame_width, 0, frame_width, frame_height)
			frames.add_frame(anim_name, atlas)

	sprite.sprite_frames = frames
	sprite.play("idle")
