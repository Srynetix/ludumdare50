extends Reference
class_name LevelFile

const LEVEL_FILE_HEADER = "LVL"
const LEVEL_FILE_VERSION = 1
const level_scene: PackedScene = preload("res://scenes/Level.tscn")

static func get_logger() -> SxLog.Logger:
    return SxLog.get_logger("LevelFile")

static func save_level(path: String, level: LevelInfo) -> void:
    var logger = get_logger()

    var file = File.new()
    var error = file.open(path, File.WRITE)
    if error != OK:
        logger.error("Could not open file '%s' for writing." % path)
        return

    logger.info("Writing level to path '%s'." % path)

    file.store_buffer(pack_level(level))
    file.close()

static func pack_level(level: LevelInfo) -> PoolByteArray:
    var buffer = StreamPeerBuffer.new()
    buffer.put_data(LEVEL_FILE_HEADER.to_ascii())
    buffer.put_64(LEVEL_FILE_VERSION)
    buffer.put_string(level.level_name)
    buffer.put_string(level.level_author)
    buffer.put_string(level.help_text)
    buffer.put_32(level.bomb_time)
    buffer.put_float(level.turret_fire_rate)
    buffer.put_8(level.wait_for_help_text)
    buffer.put_8(level.lock_camera)
    buffer.put_var(level.background_tiles)
    buffer.put_var(level.middleground_tiles)
    buffer.put_var(level.foreground_tiles)
    return SxBuffer.zstd_compress(buffer.data_array)

static func unpack_level(array: PoolByteArray) -> LevelInfo:
    var logger = get_logger()
    var level = LevelInfo.new()
    var buffer = StreamPeerBuffer.new()
    buffer.data_array = SxBuffer.zstd_decompress(array)

    var _array = buffer.get_data(len(LEVEL_FILE_HEADER.to_ascii()))
    var header = _array[1].get_string_from_ascii()
    if header != LEVEL_FILE_HEADER:
        logger.error("Wrong file header. '%s' != '%s'" % [LEVEL_FILE_HEADER, header])
        return level

    var version = buffer.get_64()
    logger.debug("Reading level file version %d" % version)

    level.level_name = buffer.get_string()
    level.level_author = buffer.get_string()
    level.help_text = buffer.get_string()
    level.bomb_time = buffer.get_32()
    level.turret_fire_rate = buffer.get_float()
    level.wait_for_help_text = bool(buffer.get_u8())
    level.lock_camera = bool(buffer.get_u8())
    level.background_tiles = buffer.get_var()
    level.middleground_tiles = buffer.get_var()
    level.foreground_tiles = buffer.get_var()
    return level

static func to_base64(level: LevelInfo) -> String:
    var packed = pack_level(level)
    return Marshalls.raw_to_base64(packed)

static func from_base64(code: String) -> LevelInfo:
    var array = Marshalls.base64_to_raw(code)
    return unpack_level(array)

static func load_level(path: String) -> LevelInfo:
    var logger = get_logger()
    var level = LevelInfo.new()

    var file = File.new()
    var error = file.open(path, File.READ)
    if error != OK:
        logger.error("Could not open file '%s' for reading." % path)
        return level

    file.seek_end()
    var size = file.get_position()
    file.seek(0)

    var data = file.get_buffer(size)
    return unpack_level(data)

static func load_scene_level(scene_path: String) -> LevelInfo:
    var level_scene := load(scene_path) as PackedScene
    var level := level_scene.instance() as Level

    var level_info = LevelInfo.new()
    level_info.level_name = level.level_name
    level_info.level_author = level.level_author
    level_info.help_text = level.help_text
    level_info.bomb_time = level.bomb_time
    level_info.turret_fire_rate = level.turret_fire_rate
    level_info.wait_for_help_text = level.wait_for_help_text
    level_info.lock_camera = level.lock_camera
    level_info.background_tiles = SxTileMap.create_dump(level.get_node("Background"))
    level_info.middleground_tiles = SxTileMap.create_dump(level.get_node("Middleground"))
    level_info.foreground_tiles = SxTileMap.create_dump(level.get_node("Foreground"))
    return level_info

static func instantiate_level(level_info: LevelInfo) -> Level:
    var level := level_scene.instance() as Level

    level.level_name = level_info.level_name
    level.level_author = level_info.level_author
    level.help_text = level_info.help_text
    level.bomb_time = int(level_info.bomb_time)
    level.turret_fire_rate = level_info.turret_fire_rate
    level.wait_for_help_text = level_info.wait_for_help_text
    level.lock_camera = level_info.lock_camera
    level.initial_background_tile_data = level_info.background_tiles
    level.initial_middleground_tile_data = level_info.middleground_tiles
    level.initial_foreground_tile_data = level_info.foreground_tiles
    return level
