extends Control

export var current_level_idx := 1
export var load_from_save := true

var _current_level: Level

const LAST_LEVEL = 999999

func _ready() -> void:
    GameData.from_game = true

    var level_id = current_level_idx
    if load_from_save:
        level_id = GameData.last_level

    _load_level(level_id)

func _choose_music(level_id: int) -> String:
    if level_id in [0, 1, 2]:
        return "track2"
    elif level_id in [3, 4, 5]:
        return "track3"
    elif level_id in [6, 7, 8]:
        return "track4"
    return "track5"

func _load_level(level_id: int) -> void:
    var level_path = "Level%02d" % level_id

    var max_level = GameData.max_level
    if max_level <= level_id:
        GameData.max_level = level_id
    GameData.last_level = level_id
    GameData.persist_to_disk()

    if _current_level != null:
        GameSceneTransitioner.fade_out()
        yield(GameSceneTransitioner, "animation_finished")
        _current_level.queue_free()

    var track: AudioStreamOGGVorbis = GameLoadCache.load_resource(_choose_music(level_id))
    GameGlobalMusicPlayer.fade_in(0.5)
    GameGlobalMusicPlayer.play_stream(track)

    # Play end game
    if !GameLoadCache.has_scene(level_path):
        GameData.last_level = level_id
        GameData.persist_to_disk()
        _current_level = GameLoadCache.instantiate_scene("LevelEnd")
    else:
        _current_level = GameLoadCache.instantiate_scene(level_path)

    var level_data = GameData.levels
    if !level_data.has(str(level_id)):
        level_id = LAST_LEVEL
    var level_item = level_data[str(level_id)]
    _current_level.level_name = level_item["name"]
    _current_level.level_author = level_item["author"]

    _current_level.connect("success", self, "_load_next_level")
    _current_level.connect("restart", self, "_reload_current_level")
    add_child(_current_level)

    GameSceneTransitioner.fade_in()
    yield(GameSceneTransitioner, "animation_finished")

    current_level_idx = level_id

func _load_next_level() -> void:
    if current_level_idx == LAST_LEVEL:
        GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameOverGoodScreen")
    else:
        _load_level(current_level_idx + 1)

func _reload_current_level() -> void:
    if current_level_idx == LAST_LEVEL:
        GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameOverScreen")
    else:
        _load_level(current_level_idx)
