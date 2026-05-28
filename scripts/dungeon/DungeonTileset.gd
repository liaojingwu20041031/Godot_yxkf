extends Node
class_name DungeonTileset

# Tile sources
enum TileSource {
	FLOOR_SAND,    # 0 - floor_sand_stone0, no collision
	FLOOR_COBBLE,  # 1 - cobble_blood1, no collision
	WALL_BROWN,    # 2 - brick_brown0, full collision
	WALL_DARK,     # 3 - brick_dark0, full collision
	PLATFORM,      # 4 - brick_brown2, one-way top collision
}

const TILE_SIZE: int = 32
const ROOM_WIDTH: int = 20
const ROOM_HEIGHT: int = 12

# Layout constants - row positions
const FLOOR_ROW_TOP: int = 10
const FLOOR_ROW_BOT: int = 11
const CEILING_ROW: int = 0
const WALL_COL_LEFT: int = 0
const WALL_COL_RIGHT: int = 19

static func create_tileset() -> TileSet:
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

	# Physics layer 0 = environment (layer 3)
	tileset.add_physics_layer(0)
	tileset.set_physics_layer_collision_layer(0, 3)

	# Source 0: floor_sand_stone0
	_add_atlas_source(tileset, 0, "res://assets/dungeon_crawl/floor/floor_sand_stone0.png", true)

	# Source 1: cobble_blood1
	_add_atlas_source(tileset, 1, "res://assets/dungeon_crawl/floor/cobble_blood1.png", true)

	# Source 2: brick_brown0 (full collision wall)
	_add_atlas_source(tileset, 2, "res://assets/dungeon_crawl/wall/brick_brown0.png", true)

	# Source 3: brick_dark0 (full collision wall variant)
	_add_atlas_source(tileset, 3, "res://assets/dungeon_crawl/wall/brick_dark0.png", true)

	# Source 4: brick_brown2 (platform with one-way top collision)
	_add_platform_source(tileset, 4, "res://assets/dungeon_crawl/wall/brick_brown2.png")

	return tileset

static func _add_atlas_source(tileset: TileSet, source_id: int, texture_path: String, has_collision: bool):
	var tex = load(texture_path)
	if not tex:
		push_warning("DungeonTileset: Failed to load " + texture_path)
		return
	var src = TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	src.create_tile(Vector2i(0, 0))
	tileset.add_source(src, source_id)
	if has_collision:
		var added_src: TileSetAtlasSource = tileset.get_source(source_id)
		var td = added_src.get_tile_data(Vector2i(0, 0), 0)
		td.set_collision_polygons_count(0, 1)
		td.set_collision_polygon_points(0, 0, PackedVector2Array([
			Vector2(0, 0), Vector2(TILE_SIZE, 0),
			Vector2(TILE_SIZE, TILE_SIZE), Vector2(0, TILE_SIZE)
		]))

static func _add_platform_source(tileset: TileSet, source_id: int, texture_path: String):
	var tex = load(texture_path)
	if not tex:
		push_warning("DungeonTileset: Failed to load " + texture_path)
		return
	var src = TileSetAtlasSource.new()
	src.texture = tex
	src.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	src.create_tile(Vector2i(0, 0))
	tileset.add_source(src, source_id)
	var added_src: TileSetAtlasSource = tileset.get_source(source_id)
	var td = added_src.get_tile_data(Vector2i(0, 0), 0)
	td.set_collision_polygons_count(0, 1)
	td.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(0, 0), Vector2(TILE_SIZE, 0),
		Vector2(TILE_SIZE, 10), Vector2(0, 10)
	]))
	td.set_collision_polygon_one_way(0, 0, true)

# Fill the entire room with dark wall tiles as background
static func fill_room_background(tilemap: TileMapLayer, wall_source: int = 3):
	for x in range(ROOM_WIDTH):
		for y in range(ROOM_HEIGHT):
			tilemap.set_cell(Vector2i(x, y), wall_source, Vector2i(0, 0))

# Build standard rectangular room: floor, walls, ceiling
static func build_standard_room(tilemap: TileMapLayer, floor_source: int = 0, wall_source: int = 2):
	# Floor (2 rows)
	for x in range(ROOM_WIDTH):
		tilemap.set_cell(Vector2i(x, FLOOR_ROW_TOP), floor_source, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(x, FLOOR_ROW_BOT), floor_source, Vector2i(0, 0))
	# Walls (left and right, all rows)
	for y in range(ROOM_HEIGHT):
		tilemap.set_cell(Vector2i(WALL_COL_LEFT, y), wall_source, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(WALL_COL_RIGHT, y), wall_source, Vector2i(0, 0))
	# Ceiling
	for x in range(ROOM_WIDTH):
		tilemap.set_cell(Vector2i(x, CEILING_ROW), wall_source, Vector2i(0, 0))

# Build room with a pit gap in the floor
static func build_pit_room(tilemap: TileMapLayer, gap_start: int = 8, gap_end: int = 11, floor_source: int = 0, wall_source: int = 2):
	for x in range(ROOM_WIDTH):
		if x < gap_start or x > gap_end:
			tilemap.set_cell(Vector2i(x, FLOOR_ROW_TOP), floor_source, Vector2i(0, 0))
			tilemap.set_cell(Vector2i(x, FLOOR_ROW_BOT), floor_source, Vector2i(0, 0))
	for y in range(ROOM_HEIGHT):
		tilemap.set_cell(Vector2i(WALL_COL_LEFT, y), wall_source, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(WALL_COL_RIGHT, y), wall_source, Vector2i(0, 0))
	for x in range(ROOM_WIDTH):
		tilemap.set_cell(Vector2i(x, CEILING_ROW), wall_source, Vector2i(0, 0))

# Build room with elevated platforms
static func build_platform_room(tilemap: TileMapLayer, platform_y: int = 4, platform_source: int = 4, floor_source: int = 0, wall_source: int = 2):
	build_standard_room(tilemap, floor_source, wall_source)
	# Low stepping stones (one jump from floor)
	for x in range(3, 6):
		tilemap.set_cell(Vector2i(x, 8), platform_source, Vector2i(0, 0))
	for x in range(14, 17):
		tilemap.set_cell(Vector2i(x, 8), platform_source, Vector2i(0, 0))
	# High platforms (one jump from stepping stones)
	for x in range(3, 8):
		tilemap.set_cell(Vector2i(x, 5), platform_source, Vector2i(0, 0))
	for x in range(12, 17):
		tilemap.set_cell(Vector2i(x, 5), platform_source, Vector2i(0, 0))

# Build room with wall pillars
static func build_pillar_room(tilemap: TileMapLayer, floor_source: int = 1, wall_source: int = 3):
	build_standard_room(tilemap, floor_source, wall_source)
	# Pillars at columns 2 and 17, rows 2 and 8
	for row in [2, 8]:
		tilemap.set_cell(Vector2i(2, row), wall_source, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(17, row), wall_source, Vector2i(0, 0))

# Build a rich combat arena with platforms and obstacles
static func build_arena_room(tilemap: TileMapLayer, floor_source: int = 0, wall_source: int = 2, platform_source: int = 4):
	build_standard_room(tilemap, floor_source, wall_source)
	# Low stepping stones (64px up from floor, easily reachable)
	for x in range(5, 8):
		tilemap.set_cell(Vector2i(x, 8), platform_source, Vector2i(0, 0))
	for x in range(12, 15):
		tilemap.set_cell(Vector2i(x, 8), platform_source, Vector2i(0, 0))
	# Central platform (64px up from stepping stones)
	for x in range(8, 12):
		tilemap.set_cell(Vector2i(x, 6), platform_source, Vector2i(0, 0))
	# High side ledges (64px up from central)
	for x in range(2, 5):
		tilemap.set_cell(Vector2i(x, 4), platform_source, Vector2i(0, 0))
	for x in range(15, 18):
		tilemap.set_cell(Vector2i(x, 4), platform_source, Vector2i(0, 0))

# Build boss arena - wide open with high platforms
static func build_boss_arena(tilemap: TileMapLayer, floor_source: int = 1, wall_source: int = 3, platform_source: int = 4):
	build_standard_room(tilemap, floor_source, wall_source)
	# Low platforms on both sides (64px up, one jump from floor)
	for x in range(2, 6):
		tilemap.set_cell(Vector2i(x, 8), platform_source, Vector2i(0, 0))
	for x in range(14, 18):
		tilemap.set_cell(Vector2i(x, 8), platform_source, Vector2i(0, 0))
	# High platforms (64px up from low platforms)
	for x in range(2, 6):
		tilemap.set_cell(Vector2i(x, 5), platform_source, Vector2i(0, 0))
	for x in range(14, 18):
		tilemap.set_cell(Vector2i(x, 5), platform_source, Vector2i(0, 0))
	# Central platform
	for x in range(8, 12):
		tilemap.set_cell(Vector2i(x, 7), platform_source, Vector2i(0, 0))

# Build treasure room with alcoves
static func build_treasure_room(tilemap: TileMapLayer, floor_source: int = 1, wall_source: int = 3):
	build_standard_room(tilemap, floor_source, wall_source)
	# Decorative side alcoves (wall insets)
	tilemap.set_cell(Vector2i(2, 6), wall_source, Vector2i(0, 0))
	tilemap.set_cell(Vector2i(17, 6), wall_source, Vector2i(0, 0))

# Build rest room with campfire area
static func build_rest_room(tilemap: TileMapLayer, floor_source: int = 0, wall_source: int = 2):
	build_standard_room(tilemap, floor_source, wall_source)
	# Small side shelves
	for x in range(2, 4):
		tilemap.set_cell(Vector2i(x, 7), TileSource.PLATFORM, Vector2i(0, 0))
	for x in range(16, 18):
		tilemap.set_cell(Vector2i(x, 7), TileSource.PLATFORM, Vector2i(0, 0))

# Build shop room
static func build_shop_room(tilemap: TileMapLayer, floor_source: int = 0, wall_source: int = 2):
	build_standard_room(tilemap, floor_source, wall_source)
	# Display shelves
	for x in range(5, 8):
		tilemap.set_cell(Vector2i(x, 6), TileSource.PLATFORM, Vector2i(0, 0))
	for x in range(12, 15):
		tilemap.set_cell(Vector2i(x, 6), TileSource.PLATFORM, Vector2i(0, 0))

# Build vertical room - platforms going upward, exit at top
static func build_vertical_room(tilemap: TileMapLayer, floor_source: int = 0, wall_source: int = 2, platform_source: int = 4):
	build_standard_room(tilemap, floor_source, wall_source)
	# Platforms ascending from left to right
	for x in range(2, 6):
		tilemap.set_cell(Vector2i(x, 8), platform_source, Vector2i(0, 0))
	for x in range(8, 12):
		tilemap.set_cell(Vector2i(x, 6), platform_source, Vector2i(0, 0))
	for x in range(14, 18):
		tilemap.set_cell(Vector2i(x, 4), platform_source, Vector2i(0, 0))
	# Top platform near exit
	for x in range(16, 19):
		tilemap.set_cell(Vector2i(x, 2), platform_source, Vector2i(0, 0))

# Build wide room - flanking platforms
static func build_wide_room(tilemap: TileMapLayer, floor_source: int = 0, wall_source: int = 2, platform_source: int = 4):
	build_standard_room(tilemap, floor_source, wall_source)
	# Left flank platform (one jump from floor)
	for x in range(1, 5):
		tilemap.set_cell(Vector2i(x, 8), platform_source, Vector2i(0, 0))
	# Right flank platform (one jump from floor)
	for x in range(15, 19):
		tilemap.set_cell(Vector2i(x, 8), platform_source, Vector2i(0, 0))
	# Center obstacle
	for x in range(9, 11):
		tilemap.set_cell(Vector2i(x, 8), wall_source, Vector2i(0, 0))

# Build trap room - pits and hazards
static func build_trap_room(tilemap: TileMapLayer, floor_source: int = 0, wall_source: int = 2):
	# Floor with gaps
	for x in range(ROOM_WIDTH):
		if x < 3 or (x > 5 and x < 9) or (x > 11 and x < 15) or x > 17:
			tilemap.set_cell(Vector2i(x, FLOOR_ROW_TOP), floor_source, Vector2i(0, 0))
			tilemap.set_cell(Vector2i(x, FLOOR_ROW_BOT), floor_source, Vector2i(0, 0))
	# Walls
	for y in range(ROOM_HEIGHT):
		tilemap.set_cell(Vector2i(WALL_COL_LEFT, y), wall_source, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(WALL_COL_RIGHT, y), wall_source, Vector2i(0, 0))
	# Ceiling
	for x in range(ROOM_WIDTH):
		tilemap.set_cell(Vector2i(x, CEILING_ROW), wall_source, Vector2i(0, 0))

# Build locked treasure room - alcove with barrier
static func build_locked_treasure_room(tilemap: TileMapLayer, floor_source: int = 1, wall_source: int = 3):
	build_standard_room(tilemap, floor_source, wall_source)
	# Treasure alcove walls
	for y in range(3, 9):
		tilemap.set_cell(Vector2i(14, y), wall_source, Vector2i(0, 0))
	# Gap in alcove wall for locked door
	tilemap.set_cell(Vector2i(14, 8), floor_source, Vector2i(0, 0))

# Create a ready-to-use TileMapLayer node
static func create_room_tilemap(layout: String = "standard", floor_source: int = 0, wall_source: int = 2) -> TileMapLayer:
	var tilemap = TileMapLayer.new()
	tilemap.name = "DungeonTileMap"
	tilemap.tile_set = create_tileset()
	match layout:
		"standard":
			build_standard_room(tilemap, floor_source, wall_source)
		"pit":
			build_pit_room(tilemap, 8, 11, floor_source, wall_source)
		"platform":
			build_platform_room(tilemap, 4, TileSource.PLATFORM, floor_source, wall_source)
		"pillar":
			build_pillar_room(tilemap, floor_source, wall_source)
		"arena":
			build_arena_room(tilemap, floor_source, wall_source)
		"boss_arena":
			build_boss_arena(tilemap, floor_source, wall_source)
		"treasure":
			build_treasure_room(tilemap, floor_source, wall_source)
		"rest":
			build_rest_room(tilemap, floor_source, wall_source)
		"shop":
			build_shop_room(tilemap, floor_source, wall_source)
		"vertical":
			build_vertical_room(tilemap, floor_source, wall_source)
		"wide":
			build_wide_room(tilemap, floor_source, wall_source)
		"trap":
			build_trap_room(tilemap, floor_source, wall_source)
		"locked_treasure":
			build_locked_treasure_room(tilemap, floor_source, wall_source)
		_:
			build_standard_room(tilemap, floor_source, wall_source)
	return tilemap

# Create a background tilemap layer (no collision, just visual)
static func create_background_tilemap(wall_source: int = 3) -> TileMapLayer:
	var tilemap = TileMapLayer.new()
	tilemap.name = "BackgroundTileMap"
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	_add_atlas_source(tileset, 0, "res://assets/dungeon_crawl/wall/brick_dark0.png", false)
	tilemap.tile_set = tileset
	# Fill entire room with dark wall background
	for x in range(ROOM_WIDTH):
		for y in range(ROOM_HEIGHT):
			tilemap.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	return tilemap
