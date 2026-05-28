extends Node2D

signal room_cleared
signal all_enemies_dead

enum RoomType { START, COMBAT, ELITE, TREASURE, SHOP, REST, SHRINE, BOSS }

@export var room_type: RoomType = RoomType.COMBAT
@export var room_layout: String = "standard"
@export var floor_variant: int = 0
@export var enemies_to_spawn: Array[PackedScene] = []
@export var spawn_points: Array[Vector2] = []
@export var dynamic_spawn_enabled: bool = true
@export var encounter_theme: String = ""

var enemies_alive: int = 0
var enemies_total: int = 0
var is_cleared: bool = false
var is_active: bool = false
var dungeon_depth: int = 0
var next_room_routes: Array[String] = []
var tracked_enemies: Array[Node] = []
var _clear_event_sent: bool = false

@onready var entrance_door: StaticBody2D = get_node_or_null("EntranceDoor")
@onready var exit_door: StaticBody2D = get_node_or_null("ExitDoor")
@onready var enemy_container: Node2D = get_node_or_null("EnemyContainer")
@onready var reward_point: Marker2D = get_node_or_null("RewardPoint")

var all_exit_doors: Array[StaticBody2D] = []
var _exit_triggered: bool = false
var _nearby_door: StaticBody2D = null
var _exit_label: Label

var _enemy_scene_paths: Dictionary = {
	"skeleton": "res://scenes/enemies/Skeleton.tscn",
	"spider": "res://scenes/enemies/Spider.tscn",
	"bat": "res://scenes/enemies/Bat.tscn",
	"slime": "res://scenes/enemies/Slime.tscn",
	"fire_mage": "res://scenes/enemies/FireMage.tscn",
	"shield_guard": "res://scenes/enemies/ShieldGuard.tscn",
}

var _route_labels: Dictionary = {
	"COMBAT": "战斗",
	"ELITE": "精英",
	"TREASURE": "宝藏",
	"SHOP": "商店",
	"REST": "篝火",
	"SHRINE": "祭坛",
	"BOSS": "首领",
}

func _ready():
	_setup_tilemap()
	_collect_exit_doors()
	_assign_exit_targets()
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

func configure_run(depth: int, routes: Array[String]):
	dungeon_depth = depth
	next_room_routes = routes.duplicate()
	if not all_exit_doors.is_empty():
		_assign_exit_targets()

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
		var label_text = _nearby_door.get("door_label_text")
		if target and target != "":
			_exit_label.text = "E 进入 %s" % (label_text if label_text and label_text != "" else target)
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
	var floor_source = _get_floor_source_for_depth()
	var wall_source = _get_wall_source_for_depth()
	var tilemap = DungeonTileset.create_room_tilemap(room_layout, floor_source, wall_source)
	add_child(tilemap)
	move_child(tilemap, 1)

func _get_floor_source_for_depth() -> int:
	if floor_variant >= 2:
		return floor_variant
	if room_type == RoomType.BOSS:
		return 6
	if dungeon_depth >= 11:
		return 7
	if dungeon_depth >= 8:
		return 6
	if dungeon_depth >= 4:
		return 5
	return floor_variant if floor_variant >= 0 else 0

func _get_wall_source_for_depth() -> int:
	if room_type == RoomType.BOSS:
		return 9
	if dungeon_depth >= 10:
		return 9
	if dungeon_depth >= 5:
		return 8
	return 2 if floor_variant == 0 else 3

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
	_assign_exit_targets()
	for door in all_exit_doors:
		if door and door.has_method("open"):
			door.open()
	is_cleared = true
	if not _clear_event_sent:
		_clear_event_sent = true
		EventBus.room_cleared.emit()
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

func _assign_exit_targets():
	if all_exit_doors.is_empty():
		return
	var routes = next_room_routes.duplicate()
	if routes.is_empty():
		var game_root = get_parent()
		if game_root and game_root.has_method("get_available_routes"):
			routes = game_root.get_available_routes()
	if routes.is_empty():
		routes.append("COMBAT")
	for i in range(all_exit_doors.size()):
		var door = all_exit_doors[i]
		if not door:
			continue
		var route = routes[i % routes.size()]
		door.set("target_room_type", route)
		door.set("door_label_text", _route_labels.get(route, route))
	_update_static_exit_labels(routes)

func _update_static_exit_labels(routes: Array):
	var label_index = 0
	for child in get_children():
		if child is Label and child.name.begins_with("ExitLabel"):
			var route = routes[label_index % routes.size()] if not routes.is_empty() else "COMBAT"
			child.text = _route_labels.get(route, route)
			label_index += 1

func _spawn_enemies():
	enemies_alive = 0
	enemies_total = 0
	tracked_enemies.clear()
	if enemy_container:
		for child in enemy_container.get_children():
			if child.is_in_group("enemies"):
				_tune_enemy_for_depth(child)
				enemies_alive += 1
				tracked_enemies.append(child)
	for i in range(enemies_to_spawn.size()):
		var enemy_scene = enemies_to_spawn[i]
		var spawn_pos = spawn_points[i] if i < spawn_points.size() else Vector2(randf_range(50, 250), 100)
		var enemy = enemy_scene.instantiate()
		enemy.position = spawn_pos
		enemy_container.add_child(enemy)
		_tune_enemy_for_depth(enemy)
		enemies_alive += 1
		tracked_enemies.append(enemy)
	_spawn_dynamic_enemies()
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

func _spawn_dynamic_enemies():
	if not dynamic_spawn_enabled or not enemy_container:
		return
	if room_type == RoomType.BOSS or room_type == RoomType.START:
		return
	var desired_count = _get_desired_enemy_count()
	var deficit = max(0, desired_count - enemies_alive)
	for i in range(deficit):
		var enemy_id = _pick_dynamic_enemy()
		var scene_path = _enemy_scene_paths.get(enemy_id, "")
		var enemy_scene = load(scene_path)
		if not enemy_scene:
			continue
		var enemy = enemy_scene.instantiate()
		enemy.position = _get_dynamic_spawn_position(i)
		enemy_container.add_child(enemy)
		_tune_enemy_for_depth(enemy)
		enemies_alive += 1
		tracked_enemies.append(enemy)

func _get_desired_enemy_count() -> int:
	var base = 2 + int(dungeon_depth / 3)
	if room_type == RoomType.ELITE:
		base += 1
	if room_layout == "wide" or room_layout == "arena":
		base += 1
	if room_layout == "trap" or room_layout == "pit":
		base = max(2, base - 1)
	return clamp(base, 2, 7)

func _pick_dynamic_enemy() -> String:
	var pool: Array[String] = ["skeleton", "spider", "slime"]
	if dungeon_depth >= 3:
		pool.append("bat")
	if dungeon_depth >= 5:
		pool.append("fire_mage")
	if dungeon_depth >= 7 or room_type == RoomType.ELITE:
		pool.append("shield_guard")
	if encounter_theme == "beasts":
		pool = ["spider", "bat", "slime"]
	elif encounter_theme == "mages":
		pool = ["fire_mage", "skeleton", "bat"]
	elif encounter_theme == "guards":
		pool = ["shield_guard", "skeleton", "fire_mage"]
	return pool[randi() % pool.size()]

func _get_dynamic_spawn_position(index: int) -> Vector2:
	var positions: Array[Vector2] = [
		Vector2(180, 308),
		Vector2(460, 308),
		Vector2(320, 308),
		Vector2(240, 244),
		Vector2(400, 244),
		Vector2(160, 180),
		Vector2(500, 180),
	]
	if room_layout == "vertical":
		positions = [
			Vector2(180, 276),
			Vector2(320, 212),
			Vector2(500, 148),
			Vector2(240, 308),
			Vector2(420, 244),
		]
	elif room_layout == "pit" or room_layout == "trap":
		positions = [
			Vector2(150, 308),
			Vector2(500, 308),
			Vector2(260, 244),
			Vector2(390, 244),
		]
	return positions[index % positions.size()]

func _tune_enemy_for_depth(enemy: Node):
	if not enemy:
		return
	var depth_scale = 1.0 + float(dungeon_depth) * 0.08
	if room_type == RoomType.ELITE:
		depth_scale += 0.35
	if enemy.get("max_health") != null:
		enemy.set("max_health", int(enemy.get("max_health") * depth_scale))
		enemy.set("current_health", enemy.get("max_health"))
	if enemy.get("attack_power") != null:
		enemy.set("attack_power", int(enemy.get("attack_power") + max(0, dungeon_depth - 2) / 2))
	if enemy.get("move_speed") != null and room_type == RoomType.ELITE:
		enemy.set("move_speed", enemy.get("move_speed") * 1.08)

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
