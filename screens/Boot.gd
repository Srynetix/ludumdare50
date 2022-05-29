extends Control

func _ready() -> void:
    GameData.store_value("from_boot", true)

    var track1: AudioStreamOGGVorbis = GameLoadCache.load_resource("track1")
    GameGlobalMusicPlayer.play_stream(track1)

func load_game() -> void:
    GameSceneTransitioner.fade_to_scene_path("res://screens/Title.tscn")