extends Control

onready var continue_btn: Button = $MarginContainer/Buttons/Continue
onready var select_level_btn: Button = $"MarginContainer/Buttons/Select Level"
onready var clear_save_data_dialog: ConfirmationDialog = $ClearSaveDataDialog
onready var clear_save_data_btn: Button = $MarginContainer2/ClearSaveData

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

    clear_save_data_btn.connect("pressed", self, "_show_clear_save_data_dialog")
    clear_save_data_dialog.connect("confirmed", self, "_clear_save_data")

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

func _show_clear_save_data_dialog() -> void:
    clear_save_data_dialog.popup_centered()