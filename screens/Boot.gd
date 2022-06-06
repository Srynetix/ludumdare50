extends Control

func _ready() -> void:
    GameData.from_boot = true

    var track1: AudioStreamOGGVorbis = GameLoadCache.load_resource("track1")
    GameGlobalMusicPlayer.play_stream(track1)

func load_game() -> void:
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "TitleScreen")