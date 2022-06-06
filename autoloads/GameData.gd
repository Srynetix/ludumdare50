extends SxGameData

var last_level: int setget _set_last_level, _get_last_level
var max_level: int setget _set_max_level, _get_max_level
var deaths: int setget _set_deaths, _get_deaths
var from_boot: bool setget _set_from_boot, _get_from_boot
var from_game: bool setget _set_from_game, _get_from_game
var levels: Dictionary setget ,_get_levels

var effects_volume: int setget _set_effects_volume, _get_effects_volume
var music_volume: int setget _set_music_volume, _get_music_volume

onready var _effects_bus_idx: int = AudioServer.get_bus_index("Effects")
onready var _music_bus_idx: int = AudioServer.get_bus_index("Music")

func _ready():
    var logger = SxLog.get_logger("SxGameData")
    logger.set_max_log_level(SxLog.LogLevel.DEBUG)
    load_from_disk()

    # Load JSON data
    store_static_value("levels", SxJson.read_json_file("res://assets/data/levels.json"))

    # Set audio buses level
    AudioServer.set_bus_volume_db(_effects_bus_idx, GameData.effects_volume)
    AudioServer.set_bus_volume_db(_music_bus_idx, GameData.music_volume)

func _get_levels() -> Dictionary:
    return load_static_value("levels", Dictionary())

func _set_last_level(value: int) -> void:
    store_value("last_level", value)

func _get_last_level() -> int:
    return int(load_value("last_level", 0))

func _set_max_level(value: int) -> void:
    store_value("max_level", value)

func _get_max_level() -> int:
    return int(load_value("max_level", 0))

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
    store_value("effects_volume", value)
    AudioServer.set_bus_volume_db(_effects_bus_idx, value)

func _get_effects_volume() -> int:
    return int(load_value("effects_volume", -3))

func _set_music_volume(value: int) -> void:
    store_value("music_volume", value)
    AudioServer.set_bus_volume_db(_music_bus_idx, value)

func _get_music_volume() -> int:
    return int(load_value("music_volume", -3))