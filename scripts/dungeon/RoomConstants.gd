class_name RoomConstants

# Unified ground anchor constants for all rooms
# Based on DungeonTileset: FLOOR_ROW_TOP = 10, TILE_SIZE = 32
# Floor top surface Y = 10 * 32 = 320

const TILE := 32
const FLOOR_TOP_Y := 320

# Player: collision height=28, origin at center → 320 - 14 = 306
const PLAYER_ORIGIN_Y := 306

# Enemy (skeleton): collision height=24 → 320 - 12 = 308
const ENEMY_ORIGIN_Y := 308

# Props (barrel, chest): collision height~28 → 320 - 14 = 306
const PROP_ORIGIN_Y := 306

# Door: collision height=48, sprite 32px → 320 - 24 = 296
const DOOR_ORIGIN_Y := 296

# Torch: visual bottom at floor → 320 - 32 = 288
const TORCH_ORIGIN_Y := 288

# Bat (flying): hover above ground
const BAT_FLY_Y := 200

# Platform Y (for platform room layout): row 4 → 4 * 32 = 128
const PLATFORM_Y := 128
