extends Node2D

signal room_cleared
signal all_enemies_dead

enum RoomType { START, COMBAT, ELITE, TREASURE, SHOP, REST, SHRINE, BOSS }

@export var room_type: RoomType = RoomType.COMBAT
@export var room_layout: String = "standard"
@export var floor_variant: int = 0
@export var enemies_to_spawn: Array[PackedScene] = []
@export var spawn_points: Array[Vector2] = []

var enemies_alive: int = 0
var enemies_total: int = 0
var is_cleared: bool = false
var is_active: bool = false
var tracked_enemies: Array[Node] = []

@onready var entrance_door: StaticBody2D = get_node_or_null("EntranceDoor")
@onready var exit_door: StaticBody2D = get_node_or_null("ExitDoor")
@onready var enemy_container: Node2D = get_node_or_null("EnemyContainer")
@onready var reward_point: Marker2D = get_node_or_null("RewardPoint")

var all_exit_doors: Array[StaticBody2D] = []
var _exit_triggered: bool = false
var _nearby_door: StaticBody2D = null
var _exit_label: Label

func _ready():
	_setup_tilemap()
	_collect_exit_doors()
	_create_exit_detections()
	_create_exit_label()
	EventBus.enemy_died.connect(_on_enemy_died)

	match room_type:
		RoomType.START:
			if entrance_door and entrance_door.has_method("open"):
				entrance_door.open()
			for door in all_exit_doors:
				if door and door.has_method("open"):
					door.open()
			is_cleared = true
		RoomType.COMBAT, RoomType.ELITE, RoomType.BOSS:
			if entrance_door and entrance_door.has_method("open"):
				entrance_door.open()
			for door in all_exit_doors:
				if door and door.has_method("close"):
					door.close()
			call_deferred("activate")
		RoomType.TREASURE:
			if entrance_door and entrance_door.has_method("open"):
				entrance_door.open()
			for door in all_exit_doors:
				if door and door.has_method("close"):
					door.close()
			call_deferred("activate")
		RoomType.SHOP, RoomType.REST, RoomType.SHRINE:
			if entrance_door and entrance_door.has_method("open"):
				entrance_door.open()
			for door in all_exit_doors:
				if door and door.has_method("open"):
					door.open()
			is_cleared = true
			call_deferred("activate")
		_:
			if entrance_door and entrance_door.has_method("open"):
				entrance_door.open()
			for door in all_exit_doors:
				if door and door.has_method("open"):
					door.open()
			is_cleared = true

func _collect_exit_doors():
	all_exit_doors.clear()
	for child in get_children():
		if child is StaticBody2D and child.name.begins_with("ExitDoor"):
			all_exit_doors.append(child)
	if all_exit_doors.is_empty() and exit_door:
		all_exit_doors.append(exit_door)

func _create_exit_detections():
	for door in all_exit_doors:
		var area = door.get_node_or_null("ExitDetection")
		if not area:
			# Create detection area as child of door
			area = Area2D.new()
			area.name = "ExitDetection"
			area.collision_layer = 0
			area.collision_mask = 1
			var shape = CollisionShape2D.new()
			var rect = RectangleShape2D.new()
			rect.size = Vector2(48, 64)
			shape.shape = rect
			area.add_child(shape)
			door.add_child(area)
		area.body_entered.connect(_on_door_entered.bind(door))
		area.body_exited.connect(_on_door_exited.bind(door))

func _create_exit_label():
	_exit_label = Label.new()
	_exit_label.name = "ExitPrompt"
	_exit_label.visible = false
	_exit_label.z_index = 100
	_exit_label.add_theme_font_size_override("font_size", 10)
	_exit_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	_exit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_exit_label.offset_left = -60
	_exit_label.offset_right = 60
	_exit_label.offset_top = -16
	_exit_label.offset_bottom = 0
	add_child(_exit_label)

func _process(_delta):
	if not is_cleared or _exit_triggered:
		_exit_label.visible = false
		return

	if _nearby_door:
		_exit_label.visible = true
		var target = _nearby_door.get("target_room_type")
		if target and target != "":
			_exit_label.text = "E 进入 %s" % target
		else:
			_exit_label.text = "E 进入下一房间"
		_exit_label.global_position = _nearby_door.global_position + Vector2(0, -40)
	else:
		_exit_label.visible = false

func _unhandled_input(event):
	if _exit_triggered:
		return
	if not is_cleared:
		return
	if not _nearby_door:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_trigger_exit(_nearby_door)

func _on_door_entered(body: Node2D, door: StaticBody2D):
	if body.is_in_group("player") and is_cleared:
		_nearby_door = door

func _on_door_exited(body: Node2D, door: StaticBody2D):
	if body.is_in_group("player") and door == _nearby_door:
		_nearby_door = null

func _trigger_exit(door: StaticBody2D):
	if _exit_triggered:
		return
	_exit_triggered = true
	var target = door.get("target_room_type") if door else ""
	print("[Exit] Player chose door -> '%s'" % target)
	if target and target != "":
		EventBus.room_exit_selected.emit(target)
	else:
		EventBus.room_cleared.emit()

func _setup_tilemap():
	if has_node("DungeonTileMap"):
		return
	if not has_node("BackgroundTileMap"):
		var bg_tilemap = DungeonTileset.create_background_tilemap()
		add_child(bg_tilemap)
		move_child(bg_tilemap, 0)
	var floor_source = floor_variant if floor_variant >= 0 else 0
	var wall_source = 2 if floor_variant == 0 else 3
	var tilemap = DungeonTileset.create_room_tilemap(room_layout, floor_source, wall_source)
	add_child(tilemap)
	move_child(tilemap, 1)

func activate():
	is_active = true
	EventBus.room_entered.emit(RoomType.keys()[room_type])
	if room_type == RoomType.COMBAT or room_type == RoomType.ELITE or room_type == RoomType.BOSS:
		_close_entrance()
		_spawn_enemies()
	elif room_type == RoomType.TREASURE:
		_spawn_treasure()
	elif room_type == RoomType.SHOP:
		_spawn_shop()
	elif room_type == RoomType.REST:
		_spawn_rest()
	elif room_type == RoomType.SHRINE:
		pass

func _close_entrance():
	if entrance_door and entrance_door.has_method("close"):
		entrance_door.close()

func _unlock_exit():
	for door in all_exit_doors:
		if door and door.has_method("open"):
			door.open()
	is_cleared = true
	var exits = _get_available_exits()
	if exits.is_empty():
		var game_root = get_parent()
		if game_root and game_root.has_method("get_available_routes"):
			exits = game_root.get_available_routes()
	if exits.size() > 1:
		EventBus.show_room_message.emit("选择出口: %s" % " / ".join(exits))
	else:
		EventBus.show_room_message.emit("出口已开启 - 走到门口按 E 进入")

func _get_available_exits() -> Array[String]:
	var exits: Array[String] = []
	for door in all_exit_doors:
		if door:
			var target = door.get("target_room_type")
			if target and target != "":
				exits.append(target)
	return exits

func _spawn_enemies():
	enemies_alive = 0
	enemies_total = 0
	tracked_enemies.clear()
	if enemy_container:
		for child in enemy_container.get_children():
			if child.is_in_group("enemies"):
				enemies_alive += 1
				tracked_enemies.append(child)
	for i in range(enemies_to_spawn.size()):
		var enemy_scene = enemies_to_spawn[i]
		var spawn_pos = spawn_points[i] if i < spawn_points.size() else Vector2(randf_range(50, 250), 100)
		var enemy = enemy_scene.instantiate()
		enemy.position = spawn_pos
		enemy_container.add_child(enemy)
		enemies_alive += 1
		tracked_enemies.append(enemy)
	enemies_total = enemies_alive
	EventBus.show_room_message.emit("击败所有敌人 0/%d" % enemies_total)
	if enemies_total <= 0 and (room_type == RoomType.COMBAT or room_type == RoomType.ELITE):
		push_warning("Combat room has no enemies, unlocking exit")
		_unlock_exit()

func _spawn_treasure():
	var prop_container = get_node_or_null("PropContainer")
	if prop_container:
		for prop in prop_container.get_children():
			if prop.has_signal("opened"):
				prop.opened.connect(_on_treasure_opened)

func _spawn_shop():
	pass

func _spawn_rest():
	pass

func _on_treasure_opened():
	_unlock_exit()

func _on_enemy_died(enemy: Node):
	if enemy in tracked_enemies:
		tracked_enemies.erase(enemy)
		enemies_alive -= 1
		var killed = enemies_total - enemies_alive
		if enemies_alive <= 0:
			all_enemies_dead.emit()
			if room_type == RoomType.BOSS:
				_unlock_exit()
				await get_tree().create_timer(2.0).timeout
				EventBus.game_over.emit(true)
			else:
				_unlock_exit()
				if room_type == RoomType.COMBAT or room_type == RoomType.ELITE:
					_show_reward()
		else:
			EventBus.show_room_message.emit("击败所有敌人 %d/%d" % [killed, enemies_total])

func _show_reward():
	var rewards = _generate_rewards()
	EventBus.show_reward_panel.emit(rewards)

func _generate_rewards() -> Array:
	var rewards = []
	var upgrade_manager = get_node_or_null("/root/UpgradeManager")
	if upgrade_manager:
		rewards = upgrade_manager.get_random_upgrades(3)
	return rewards
