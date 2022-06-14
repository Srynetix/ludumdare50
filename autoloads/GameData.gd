extends SxGameData

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
var deaths: int setget _set_deaths, _get_deaths
var from_boot: bool setget _set_from_boot, _get_from_boot
var from_game: bool setget _set_from_game, _get_from_game

var effects_volume: int setget _set_effects_volume, _get_effects_volume
var music_volume: int setget _set_music_volume, _get_music_volume

onready var _effects_bus_idx: int = AudioServer.get_bus_index("Effects")
onready var _music_bus_idx: int = AudioServer.get_bus_index("Music")

func _ready():
    var logger = SxLog.get_logger("SxGameData")
    logger.set_max_log_level(SxLog.LogLevel.DEBUG)
    load_from_disk()

    # Init
    _last_level = _load_last_level()

    # Set audio buses level
    AudioServer.set_bus_volume_db(_effects_bus_idx, GameData.effects_volume)
    AudioServer.set_bus_volume_db(_music_bus_idx, GameData.music_volume)

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

func _get_deaths() -> int:
    return int(load_value("deaths", 0))

func _set_from_boot(value: bool) -> void:
    store_value("from_boot", value)

func _get_from_boot() -> bool:
    return bool(load_value("from_boot", false))

func _set_from_game(value: bool) -> void:
    store_value("from_game", value)

func _get_from_game() -> bool:
    return bool(load_value("from_game", false))

func _set_effects_volume(value: int) -> void:
    store_value("effects_volume", value, "options")
    AudioServer.set_bus_volume_db(_effects_bus_idx, value)

func _get_effects_volume() -> int:
    return int(load_value("effects_volume", -3, "options"))

func _set_music_volume(value: int) -> void:
    store_value("music_volume", value, "options")
    AudioServer.set_bus_volume_db(_music_bus_idx, value)

func _get_music_volume() -> int:
    return int(load_value("music_volume", -3, "options"))