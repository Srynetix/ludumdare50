extends Control

onready var author: RichTextLabel = $MarginContainer3/Author
onready var continue_btn: Button = $MarginContainer/Buttons/Continue
onready var select_level_btn: Button = $"MarginContainer/Buttons/Select Level"
onready var clear_save_data_confirm: FullScreenConfirmationDialog = $ClearSaveDataConfirm
onready var new_game_confirm: FullScreenConfirmationDialog = $ConfirmNewGame
onready var clear_save_data_btn: Button = $MarginContainer2/ClearSaveData

func _ready() -> void:
    get_tree().set_quit_on_go_back(true)

    if GameData.from_boot:
        GameData.remove("from_boot")
    else:
        var track1: AudioStreamOGGVorbis = GameLoadCache.load_resource("track1")
        GameGlobalMusicPlayer.fade_in()
        GameGlobalMusicPlayer.play_stream(track1)

    # Insert version in about text
    author.bbcode_text = author.bbcode_text % ProjectSettings.get_setting("global/game_version")

    # Get last collection
    var can_continue = GameData.get_max_level(LevelCollection.DEFAULT_COLLECTION) > 0
    continue_btn.visible = can_continue

    clear_save_data_btn.connect("pressed", self, "_show_clear_save_data_panel")
    clear_save_data_confirm.connect("confirmed", self, "_clear_save_data")
    new_game_confirm.connect("confirmed", self, "_start_new_game")

func start_game() -> void:
    GameGlobalMusicPlayer.fade_out()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameScreen")

func start_new_game() -> void:
    var last_level = GameData.get_last_level()
    if GameData.get_max_level(last_level.collection) > 0:
        new_game_confirm.fade_in()
    else:
        _start_new_game()

func _start_new_game() -> void:
    GameGlobalMusicPlayer.fade_out()
    GameData.reset_last_level(LevelCollection.DEFAULT_COLLECTION)
    GameData.set_max_level(LevelCollection.DEFAULT_COLLECTION, 0)
    GameData.deaths = 0
    GameData.persist_to_disk()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameScreen")

func start_editor() -> void:
    GameGlobalMusicPlayer.fade_out()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "EditorScreen")

func options() -> void:
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "OptionsScreen")

func level_selector() -> void:
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "LevelSelectorScreen")

func _clear_save_data() -> void:
    GameData.clear()
    GameData.persist_to_disk()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "BootScreen")

func _show_clear_save_data_panel() -> void:
    clear_save_data_confirm.fade_in()

func _exit_tree():
    get_tree().set_quit_on_go_back(false)