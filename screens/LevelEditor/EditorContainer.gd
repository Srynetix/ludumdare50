extends Control

const GridPanel = preload("res://screens/LevelEditor/GridPanel.gd")
const DetailPanel = preload("res://screens/LevelEditor/DetailPanel.gd")
const MapLayer = GridPanel.MapLayer

onready var top_container: MarginContainer = $Panel/TopContainer
onready var details_btn: Button = $Panel/TopContainer/TopBar/Left/Details
onready var background_btn: Button = $Panel/TopContainer/TopBar/Left/Background
onready var middleground_btn: Button = $Panel/TopContainer/TopBar/Left/Middleground
onready var foreground_btn: Button = $Panel/TopContainer/TopBar/Left/Foreground

onready var play_btn: Button = $Panel/TopContainer/TopBar/Right/Play
onready var save_btn: Button = $Panel/TopContainer/TopBar/Right/Save
onready var load_btn: Button = $Panel/TopContainer/TopBar/Right/Load
onready var exit_btn: Button = $Panel/TopContainer/TopBar/Right/Exit

onready var stop_btn: Button = $LevelPanel/GameOverlay/ParentOverlay/TopContainer/TopBar/Right/Stop

onready var main_panel: Panel = $Panel
onready var detail_panel: DetailPanel = $Panel/DetailPanelContainer/DetailPanel
onready var grid_panel: GridPanel = $Panel/GridPanel
onready var level_panel: Panel = $LevelPanel
onready var overlay_container: Control = $LevelPanel/GameOverlay/ParentOverlay
onready var level_container: Control = $LevelPanel/LevelContainer
onready var save_dialog: FileDialog = $SaveDialog
onready var load_dialog: FileDialog = $LoadDialog
onready var exit_dialog: ConfirmationDialog = $ExitDialog

var level_scene: PackedScene = preload("res://scenes/Level.tscn")
var current_panel: Control = null
var current_level: Level = null

func _ready() -> void:
    details_btn.connect("pressed", self, "_show_panel", [ "details" ])
    background_btn.connect("pressed", self, "_show_panel", [ "background" ])
    middleground_btn.connect("pressed", self, "_show_panel", [ "middleground" ])
    foreground_btn.connect("pressed", self, "_show_panel", [ "foreground" ])
    play_btn.connect("pressed", self, "_play_level")
    stop_btn.connect("pressed", self, "_stop_level")
    save_btn.connect("pressed", self, "_open_save_dialog")
    load_btn.connect("pressed", self, "_open_load_dialog")
    exit_btn.connect("pressed", self, "_open_exit_dialog")
    save_dialog.connect("file_selected", self, "_save_level")
    load_dialog.connect("file_selected", self, "_load_level")
    exit_dialog.connect("confirmed", self, "_exit_editor")

    current_panel = grid_panel

func _show_panel(panel_type: String) -> void:
    if current_panel != null:
        current_panel.hide()

    if panel_type == "details":
        detail_panel.show()
        current_panel = detail_panel
    elif panel_type == "background":
        grid_panel.show()
        grid_panel.set_current_tilemap_layer(MapLayer.BACKGROUND)
        current_panel = grid_panel
    elif panel_type == "middleground":
        grid_panel.show()
        grid_panel.set_current_tilemap_layer(MapLayer.MIDDLEGROUND)
        current_panel = grid_panel
    elif panel_type == "foreground":
        grid_panel.show()
        grid_panel.set_current_tilemap_layer(MapLayer.FOREGROUND)
        current_panel = grid_panel

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        var event_key: InputEventKey = event
        if event_key.pressed && event_key.scancode == KEY_H:
            _toggle_ui()
        elif event_key.pressed && event_key.scancode == KEY_ENTER:
            if current_level:
                _stop_level()
                _play_level()
        elif event_key.pressed && event_key.scancode == KEY_ESCAPE:
            if current_level:
                _stop_level()

func _toggle_ui() -> void:
    top_container.visible = !top_container.visible
    grid_panel.toggle_ui()

func _play_level() -> void:
    main_panel.hide()

    var level: Level = level_scene.instance()
    level.level_author = detail_panel.level_author.text
    level.level_name = detail_panel.level_name.text
    level.help_text = detail_panel.help_text.text
    level.bomb_time = detail_panel.bomb_time.value
    level.editor_mode = true
    level.turret_fire_rate = detail_panel.turret_fire_rate.value
    level.wait_for_help_text = detail_panel.wait_for_help_text.pressed
    level.lock_camera = detail_panel.lock_camera.pressed
    level.initial_background_tile_data = SxTileMap.create_dump(grid_panel.background_tilemap)
    level.initial_middleground_tile_data = SxTileMap.create_dump(grid_panel.middleground_tilemap)
    level.initial_foreground_tile_data = SxTileMap.create_dump(grid_panel.foreground_tilemap)

    level_container.add_child(level)
    level_panel.show()
    overlay_container.show()
    current_level = level

func _stop_level() -> void:
    level_panel.hide()
    overlay_container.hide()
    current_level.queue_free()
    main_panel.show()

func _open_save_dialog() -> void:
    var levels = Directory.new()
    if levels.open("user://levels") != OK:
        levels.make_dir("user://levels")

    save_dialog.invalidate()
    save_dialog.popup_centered_minsize(Vector2(200, 200))

func _open_exit_dialog() -> void:
    exit_dialog.popup_centered()

func _open_load_dialog() -> void:
    var levels = Directory.new()
    if levels.open("user://levels") != OK:
        levels.make_dir("user://levels")

    load_dialog.invalidate()
    load_dialog.popup_centered_minsize(Vector2(200, 200))

func _save_level(path: String) -> void:
    var dump = Dictionary()
    dump["level_name"] = detail_panel.level_name.text
    dump["level_author"] = detail_panel.level_author.text
    dump["help_text"] = detail_panel.help_text.text
    dump["bomb_time"] = detail_panel.bomb_time.value
    dump["turret_fire_rate"] = detail_panel.turret_fire_rate.value
    dump["wait_for_help_text"] = detail_panel.wait_for_help_text.pressed
    dump["lock_camera"] = detail_panel.lock_camera.pressed
    dump["initial_background_tile_data"] = SxTileMap.create_dump(grid_panel.background_tilemap)
    dump["initial_middleground_tile_data"] = SxTileMap.create_dump(grid_panel.middleground_tilemap)
    dump["initial_foreground_tile_data"] = SxTileMap.create_dump(grid_panel.foreground_tilemap)

    SxJson.write_json_file(dump, path)

func _load_level(path: String) -> void:
    var dump = SxJson.read_json_file(path)

    detail_panel.level_name.text = dump["level_name"]
    detail_panel.level_author.text = dump["level_author"]
    detail_panel.help_text.text = dump["help_text"]
    detail_panel.bomb_time.value = dump["bomb_time"]
    detail_panel.turret_fire_rate.value = dump["turret_fire_rate"]
    detail_panel.wait_for_help_text.pressed = dump["wait_for_help_text"]
    detail_panel.lock_camera.pressed = dump["lock_camera"]
    SxTileMap.load_dump(grid_panel.background_tilemap, dump["initial_background_tile_data"])
    SxTileMap.load_dump(grid_panel.middleground_tilemap, dump["initial_middleground_tile_data"])
    SxTileMap.load_dump(grid_panel.foreground_tilemap, dump["initial_foreground_tile_data"])

func _exit_editor() -> void:
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "TitleScreen")
