extends Control

onready var continue_btn: Button = $MarginContainer/Buttons/Continue

func _ready() -> void:
    if GameData.load_value("from_boot", false):
        GameData.remove("from_boot")
    else:
        var track1: AudioStreamOGGVorbis = GameLoadCache.load_resource("track1")
        GameGlobalMusicPlayer.fade_in()
        GameGlobalMusicPlayer.play_stream(track1)

    var can_continue = GameData.load_value("last_level", -1) != -1
    continue_btn.visible = can_continue

func start_game() -> void:
    GameGlobalMusicPlayer.fade_out()
    GameSceneTransitioner.fade_to_scene_path("res://screens/Game.tscn")

func start_new_game() -> void:
    GameGlobalMusicPlayer.fade_out()
    GameData.store_value("last_level", 0)
    GameData.store_value("deaths", 0)
    GameData.persist_to_disk()
    GameSceneTransitioner.fade_to_scene_path("res://screens/Game.tscn")