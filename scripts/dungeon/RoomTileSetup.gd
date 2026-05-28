extends Node

# Tile size matching the crawl tiles (32x32)
const TILE_SIZE: int = 32

# Room dimensions (640x360 viewport)
const ROOM_WIDTH: int = 20   # 640/32
const ROOM_HEIGHT: int = 12  # 384/32 (slightly over for ceiling)

static func create_dungeon_tileset() -> TileSet:
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)

	# Add physics layer for walls
	tileset.add_physics_layer(0)
	tileset.set_physics_layer_collision_layer(0, 3)  # environment layer

	# Floor tiles source
	var floor_source = TileSetAtlasSource.new()
	var floor_tex = load("res://assets/dungeon_crawl/floor/floor_sand_stone0.png")
	if floor_tex:
		floor_source.texture = floor_tex
		floor_source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
		floor_source.create_tile(Vector2i(0, 0))
		tileset.add_source(floor_source, 0)

	# Wall tiles source
	var wall_source = TileSetAtlasSource.new()
	var wall_tex = load("res://assets/dungeon_crawl/wall/brick_brown0.png")
	if wall_tex:
		wall_source.texture = wall_tex
		wall_source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
		wall_source.create_tile(Vector2i(0, 0))
		# Set physics collision for wall tile
		var tile_data = wall_source.get_tile_data(Vector2i(0, 0), 0)
		tile_set_physics(tileset, wall_source, Vector2i(0, 0))
		tileset.add_source(wall_source, 1)

	return tileset

static func tile_set_physics(tileset: TileSet, source: TileSetAtlasSource, coords: Vector2i):
	var data = source.get_tile_data(coords, 0)
	# Create a full-tile collision polygon
	var polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(TILE_SIZE, 0),
		Vector2(TILE_SIZE, TILE_SIZE),
		Vector2(0, TILE_SIZE)
	])
	data.set_collision_polygons_count(0, 1)
	data.set_collision_polygon_points(0, 0, polygon)

static func build_room_tilemap(tilemap: TileMapLayer, room_type: String = "combat"):
	# Build floor
	for x in range(ROOM_WIDTH):
		tilemap.set_cell(Vector2i(x, ROOM_HEIGHT - 1), 0, Vector2i(0, 0))  # floor
		tilemap.set_cell(Vector2i(x, ROOM_HEIGHT - 2), 0, Vector2i(0, 0))  # floor 2nd row

	# Build walls (left and right)
	for y in range(ROOM_HEIGHT):
		tilemap.set_cell(Vector2i(0, y), 1, Vector2i(0, 0))              # left wall
		tilemap.set_cell(Vector2i(ROOM_WIDTH - 1, y), 1, Vector2i(0, 0)) # right wall

	# Build ceiling
	for x in range(ROOM_WIDTH):
		tilemap.set_cell(Vector2i(x, 0), 1, Vector2i(0, 0))

static func create_room_tilemap_node(room_type: String = "combat") -> TileMapLayer:
	var tilemap = TileMapLayer.new()
	tilemap.name = "DungeonTileMap"
	tilemap.tile_set = create_dungeon_tileset()
	build_room_tilemap(tilemap, room_type)
	return tilemap
