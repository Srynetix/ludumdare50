extends Control

const GridPanel = preload("res://screens/LevelEditor/GridPanel.gd")
const DetailPanel = preload("res://screens/LevelEditor/DetailPanel.gd")

enum EditorPanel {
    GRID = 0,
    DETAILS,
    HELP
}

onready var top_container: MarginContainer = $Panel/TopContainer
onready var details_btn: Button = $Panel/TopContainer/TopBar/Left/Details
onready var help_btn: Button = $Panel/TopContainer/TopBar/Left/Help
onready var grid_btn: Button = $Panel/TopContainer/TopBar/Left/Grid

onready var play_btn: Button = $Panel/TopContainer/TopBar/Right/Play
onready var save_btn: MenuButton = $Panel/TopContainer/TopBar/Right/Save
onready var load_btn: MenuButton = $Panel/TopContainer/TopBar/Right/Load
onready var new_btn: Button = $Panel/TopContainer/TopBar/Right/New
onready var exit_btn: Button = $Panel/TopContainer/TopBar/Right/Exit
onready var stop_btn: Button = $LevelPanel/GameOverlay/ParentOverlay/TopContainer/TopBar/Right/Stop

onready var main_panel: Panel = $Panel
onready var detail_panel: DetailPanel = $Panel/DetailPanelContainer/DetailPanel
onready var grid_panel: GridPanel = $Panel/GridPanel
onready var help_panel: MarginContainer = $Panel/HelpPanel
onready var level_panel: Panel = $LevelPanel
onready var overlay_container: Control = $LevelPanel/GameOverlay/ParentOverlay
onready var level_container: Control = $LevelPanel/LevelContainer

onready var save_dialog: FileDialog = $Dialogs/SaveDialog
onready var save_system_dialog: FileDialog = $Dialogs/SaveSystemDialog
onready var load_dialog: FileDialog = $Dialogs/LoadDialog
onready var load_scene_dialog: FileDialog = $Dialogs/LoadSceneDialog
onready var load_system_dialog: FileDialog = $Dialogs/LoadSystemDialog
onready var exit_dialog: FullScreenConfirmationDialog = $Dialogs/ExitActionConfirmation
onready var export_dialog: AcceptDialog = $Dialogs/ExportDialog
onready var import_dialog: AcceptDialog = $Dialogs/ImportDialog
onready var new_dialog: FullScreenConfirmationDialog = $Dialogs/NewActionConfirmation

var level_scene: PackedScene = preload("res://scenes/Level.tscn")
var current_panel: Control = null
var current_level: Level = null

var logger = SxLog.get_logger("Editor")

func _ready() -> void:
    details_btn.connect("pressed", self, "_show_panel", [ EditorPanel.DETAILS ])
    grid_btn.connect("pressed", self, "_show_panel", [ EditorPanel.GRID ])
    help_btn.connect("pressed", self, "_show_panel", [ EditorPanel.HELP ])
    play_btn.connect("pressed", self, "_play_level")
    stop_btn.connect("pressed", self, "_stop_level")
    save_btn.get_popup().connect("id_pressed", self, "_open_save_dialog")
    load_btn.get_popup().connect("id_pressed", self, "_open_load_dialog")
    new_btn.connect("pressed", self, "_open_new_dialog")
    exit_btn.connect("pressed", self, "_open_exit_dialog")

    # Dialogs
    save_dialog.connect("file_selected", self, "_save_level")
    save_system_dialog.connect("file_selected", self, "_save_level")
    load_dialog.connect("file_selected", self, "_load_level")
    load_scene_dialog.connect("file_selected", self, "_load_scene_level")
    load_system_dialog.connect("file_selected", self, "_load_level")
    exit_dialog.connect("confirmed", self, "_exit_editor")
    import_dialog.connect("confirmed", self, "_load_base64_level")
    new_dialog.connect("confirmed", self, "_reset_editor")

    # Clipboard
    var copy_to_clipboard_btn: Button = export_dialog.get_node("MarginContainer/VBoxContainer/Button")
    var copy_from_clipboard_btn: Button = import_dialog.get_node("MarginContainer/VBoxContainer/Button")
    copy_to_clipboard_btn.connect("pressed", self, "_copy_to_clipboard")
    copy_from_clipboard_btn.connect("pressed", self, "_copy_from_clipboard")

    # Copy font
    save_btn.get_popup().set("custom_fonts/font", save_btn.get("custom_fonts/font"))
    load_btn.get_popup().set("custom_fonts/font", load_btn.get("custom_fonts/font"))

    current_panel = grid_panel

    _load_scene_inner(LevelInfo.new())

func _show_panel(panel_type: int) -> void:
    if current_panel != null:
        current_panel.hide()

    if panel_type == EditorPanel.DETAILS:
        detail_panel.show()
        current_panel = detail_panel
    elif panel_type == EditorPanel.GRID:
        grid_panel.show()
        current_panel = grid_panel
    elif panel_type == EditorPanel.HELP:
        help_panel.show()
        current_panel = help_panel

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

    var level_info = _build_level()
    var level = LevelFile.instantiate_level(level_info)
    level.editor_mode = true

    level_container.add_child(level)
    level_panel.show()
    overlay_container.show()
    current_level = level

func _stop_level() -> void:
    level_panel.hide()
    overlay_container.hide()
    current_level.queue_free()
    main_panel.show()

func _copy_to_clipboard() -> void:
    var text_edit = export_dialog.get_node("MarginContainer/VBoxContainer/TextEdit")
    OS.set_clipboard(text_edit.text)

func _copy_from_clipboard() -> void:
    var text_edit = import_dialog.get_node("MarginContainer/VBoxContainer/TextEdit")
    text_edit.text = OS.get_clipboard()

func _open_save_dialog(menu_id: int) -> void:
    if menu_id == 0:
        var levels = Directory.new()
        if levels.open("user://levels") != OK:
            levels.make_dir("user://levels")

        save_dialog.invalidate()
        save_dialog.popup_centered_minsize(Vector2(200, 200))
    elif menu_id == 1:
        save_system_dialog.invalidate()
        save_system_dialog.popup_centered_minsize(Vector2(200, 200))
    elif menu_id == 2:
        # Base64
        var level = _build_level()
        var text_edit: TextEdit = export_dialog.get_node("MarginContainer/VBoxContainer/TextEdit")
        text_edit.text = LevelFile.to_base64(level)
        export_dialog.popup_centered()

func _open_exit_dialog() -> void:
    exit_dialog.fade_in()

func _open_new_dialog() -> void:
    new_dialog.fade_in()

func _open_load_dialog(menu_id: int) -> void:
    if menu_id == 0:
        # Binary
        var levels = Directory.new()
        if levels.open("user://levels") != OK:
            levels.make_dir("user://levels")

        load_dialog.invalidate()
        load_dialog.popup_centered_minsize(Vector2(200, 200))
    elif menu_id == 1:
        # Scene
        load_scene_dialog.invalidate()
        load_scene_dialog.popup_centered_minsize(Vector2(200, 200))
    elif menu_id == 2:
        # Binary (system)
        load_system_dialog.invalidate()
        load_system_dialog.popup_centered_minsize(Vector2(200, 200))
    elif menu_id == 3:
        # Base64
        import_dialog.popup_centered()

func _save_level(path: String) -> void:
    var level = _build_level()
    LevelFile.save_level(path, level)

func _build_level() -> LevelInfo:
    var level = LevelInfo.new()
    level.level_name = detail_panel.level_name.text
    level.level_author = detail_panel.level_author.text
    level.help_text = detail_panel.help_text.text
    level.bomb_time = detail_panel.bomb_time.value
    level.turret_fire_rate = detail_panel.turret_fire_rate.value
    level.wait_for_help_text = detail_panel.wait_for_help_text.pressed
    level.lock_camera = detail_panel.lock_camera.pressed
    level.background_tiles = SxTileMap.create_dump(grid_panel.background_tilemap)
    level.middleground_tiles = SxTileMap.create_dump(grid_panel.middleground_tilemap)
    level.foreground_tiles = SxTileMap.create_dump(grid_panel.foreground_tilemap)
    return level

func _load_level(path: String) -> void:
    var level = LevelFile.load_level(path)
    _load_scene_inner(level)

func _load_scene_level(path: String) -> void:
    var level = LevelFile.load_scene_level(path)
    _load_scene_inner(level)

func _load_base64_level() -> void:
    var text_edit: TextEdit = import_dialog.get_node("MarginContainer/VBoxContainer/TextEdit")
    var base64 = text_edit.text
    var level = LevelFile.from_base64(base64)
    if level.level_name == "":
        logger.error("Corrupted base64, did not load level")
    else:
        _load_scene_inner(level)

func _load_scene_inner(level: LevelInfo) -> void:
    detail_panel.level_name.text = level.level_name
    detail_panel.level_author.text = level.level_author
    detail_panel.help_text.text = level.help_text
    detail_panel.bomb_time.value = level.bomb_time
    detail_panel.turret_fire_rate.value = level.turret_fire_rate
    detail_panel.wait_for_help_text.pressed = level.wait_for_help_text
    detail_panel.lock_camera.pressed = level.lock_camera
    SxTileMap.apply_dump(grid_panel.background_tilemap, level.background_tiles)
    SxTileMap.apply_dump(grid_panel.middleground_tilemap, level.middleground_tiles)
    SxTileMap.apply_dump(grid_panel.foreground_tilemap, level.foreground_tiles)

    # Load grid panel
    _show_panel(EditorPanel.GRID)

func _reset_editor() -> void:
    _load_scene_inner(LevelInfo.new())

func _exit_editor() -> void:
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "TitleScreen")
