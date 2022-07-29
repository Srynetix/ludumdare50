extends SxGameData

const _DEFAULT_RESOLUTION = "832x480"

class LastLevel:
    var collection: String
    var level_id: int

    func to_array() -> Array:
        return [collection, level_id]

    static func from_array(array: Array) -> LastLevel:
        var level = LastLevel.new()
        level.collection = array[0]
        level.level_id = array[1]
        return level

    static func from_collection(collection_: String, level_id_: int) -> LastLevel:
        var level = LastLevel.new()
        level.collection = collection_
        level.level_id = level_id_
        return level

# Private
var _max_levels := Dictionary()
var _last_level := LastLevel.new()

# Values
var deaths: int setget _set_deaths
var from_boot: bool setget _set_from_boot
var resolution: String setget _set_resolution
var effects_volume: float setget _set_effects_volume
var music_volume: float setget _set_music_volume

onready var _effects_bus_idx := AudioServer.get_bus_index("Effects")
onready var _music_bus_idx := AudioServer.get_bus_index("Music")

func _ready():
    var logger = SxLog.get_logger("SxGameData")
    logger.set_max_log_level(SxLog.LogLevel.DEBUG)
    load_from_disk()
    get_tree().set_quit_on_go_back(false)

    # Init
    _last_level = _load_last_level()

    _set_deaths(int(load_value("deaths", 0)))
    _set_from_boot(bool(load_value("from_boot", false)))
    _set_effects_volume(int(load_value("effects_volume", -6, "options")))
    _set_music_volume(int(load_value("music_volume", -12, "options")))
    _set_resolution(load_value("resolution", _DEFAULT_RESOLUTION, "options"))

func _set_resolution(value: String) -> void:
    resolution = value
    SxOS.set_window_size_str(value)
    store_value("resolution", value, "options")

func set_max_level(collection_name: String, max_level: int) -> void:
    _max_levels[collection_name] = max_level
    store_value("max_levels", _max_levels)

func get_max_level(collection_name: String) -> int:
    _max_levels = load_value("max_levels", Dictionary())
    if _max_levels.has(collection_name):
        return _max_levels[collection_name]
    return 0

func reset_last_level(collection_name: String) -> void:
    set_last_level(collection_name, 0)

func set_last_level(collection_name: String, id: int) -> void:
    _last_level.collection = collection_name
    _last_level.level_id = id
    store_value("last_level_collection", _last_level.to_array())

func get_last_level() -> LastLevel:
    return _last_level

func _load_last_level() -> LastLevel:
    var value = load_value("last_level_collection", null)
    if value == null:
        return LastLevel.from_array([LevelCollection.DEFAULT_COLLECTION, 0])
    return LastLevel.from_array(value)

func _set_deaths(value: int) -> void:
    store_value("deaths", value)

func _set_from_boot(value: bool) -> void:
    store_value("from_boot", value)

func _set_effects_volume(value: float) -> void:
    effects_volume = value
    store_value("effects_volume", value, "options")
    AudioServer.set_bus_volume_db(_effects_bus_idx, value)

func _set_music_volume(value: float) -> void:
    music_volume = value
    store_value("music_volume", value, "options")
    AudioServer.set_bus_volume_db(_music_bus_idx, value)