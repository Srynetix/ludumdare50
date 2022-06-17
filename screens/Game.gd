extends Control

var _current_level_idx := 0
var _current_level: Level = null
var _collection := LevelCollection.new()

func _ready() -> void:
    var last_level = GameData.get_last_level()
    _collection.load_collection(last_level.collection)
    _current_level_idx = last_level.level_id
    _load_level()

func _choose_music() -> String:
    if _collection.collection_folder == "ld50":
        if _current_level_idx in [0, 1, 2]:
            return "track2"
        elif _current_level_idx in [3, 4, 5]:
            return "track3"
        elif _current_level_idx in [6, 7, 8]:
            return "track4"
        return "track5"
    else:
        return "track2"

func _load_level() -> void:
    var max_level = GameData.get_max_level(_collection.collection_folder)
    if max_level <= _current_level_idx:
        GameData.set_max_level(_collection.collection_folder, _current_level_idx)
    GameData.set_last_level(_collection.collection_folder, _current_level_idx)
    GameData.persist_to_disk()

    if _current_level != null:
        GameSceneTransitioner.fade_out()
        yield(GameSceneTransitioner, "animation_finished")
        _current_level.queue_free()

    var track: AudioStreamOGGVorbis = GameLoadCache.load_resource(_choose_music())
    GameGlobalMusicPlayer.fade_in(0.5)
    GameGlobalMusicPlayer.play_stream(track)

    _current_level = LevelFile.instantiate_level(_collection.levels[_current_level_idx])
    _current_level.connect("success", self, "_load_next_level")
    _current_level.connect("restart", self, "_reload_current_level")
    add_child(_current_level)

    GameSceneTransitioner.fade_in()
    yield(GameSceneTransitioner, "animation_finished")

func _load_next_level() -> void:
    if _current_level_idx == len(_collection.levels) - 1:
        if _collection.collection_folder == "ld50":
            GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameOverGoodScreen")
        else:
            GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "LevelSelectorScreen")
    else:
        _current_level_idx += 1
        _load_level()

func _reload_current_level() -> void:
    if _current_level_idx == len(_collection.levels) - 1 && _collection.collection_folder == "ld50":
        GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameOverScreen")
    else:
        _load_level()

func _unhandled_input(event: InputEvent):
    if event is InputEventKey:
        var event_key: InputEventKey = event
        if event_key.pressed && event_key.scancode == KEY_ESCAPE:
            GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "TitleScreen")
