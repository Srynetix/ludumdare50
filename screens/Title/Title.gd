extends Control

onready var continue_btn: Button = $MarginContainer/Buttons/Continue
onready var select_level_btn: Button = $"MarginContainer/Buttons/Select Level"
onready var clear_save_data_panel: Panel = $ClearSaveDataOverlay
onready var clear_save_data_btn: Button = $MarginContainer2/ClearSaveData

onready var clear_save_data_tween: Tween = $ClearSaveDataOverlay/Tween
onready var clear_save_data_yes: Button = $ClearSaveDataOverlay/VBoxContainer/HBoxContainer/Yes
onready var clear_save_data_no: Button = $ClearSaveDataOverlay/VBoxContainer/HBoxContainer/No

func _ready() -> void:
    if GameData.from_boot:
        GameData.remove("from_boot")
    else:
        var track1: AudioStreamOGGVorbis = GameLoadCache.load_resource("track1")
        GameGlobalMusicPlayer.fade_in()
        GameGlobalMusicPlayer.play_stream(track1)

    var can_continue = GameData.last_level > 0
    continue_btn.visible = can_continue
    select_level_btn.visible = can_continue

    clear_save_data_btn.connect("pressed", self, "_show_clear_save_data_panel")
    clear_save_data_no.connect("pressed", self, "_hide_clear_save_data_panel")
    clear_save_data_yes.connect("pressed", self, "_clear_save_data")

func start_game() -> void:
    GameGlobalMusicPlayer.fade_out()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameScreen")

func start_new_game() -> void:
    GameGlobalMusicPlayer.fade_out()
    GameData.last_level = 0
    GameData.max_level = 0
    GameData.deaths = 0
    GameData.persist_to_disk()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameScreen")

func options() -> void:
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "OptionsScreen")

func level_selector() -> void:
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "LevelSelectorScreen")

func _clear_save_data() -> void:
    GameData.clear()
    GameData.persist_to_disk()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "BootScreen")

func _show_clear_save_data_panel() -> void:
    clear_save_data_tween.stop_all()
    clear_save_data_panel.visible = true
    clear_save_data_tween.interpolate_property(clear_save_data_panel, "modulate", Color.transparent, Color.white, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    clear_save_data_tween.start()

func _hide_clear_save_data_panel() -> void:
    clear_save_data_tween.stop_all()
    clear_save_data_tween.interpolate_property(clear_save_data_panel, "modulate", Color.white, Color.transparent, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    clear_save_data_tween.start()
    yield(clear_save_data_tween, "tween_all_completed")
    clear_save_data_panel.visible = false