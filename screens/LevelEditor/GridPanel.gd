extends Control

enum MapLayer {
    BACKGROUND = 0,
    MIDDLEGROUND,
    FOREGROUND
}

const TilesPanel = preload("res://screens/LevelEditor/TilesPanel.gd")
const ToolMode = TilesPanel.ToolMode

onready var background_tilemap: TileMap = $Middle/BackgroundTileMap
onready var middleground_tilemap: TileMap = $Middle/MiddlegroundTileMap
onready var foreground_tilemap: TileMap = $Middle/ForegroundTileMap
onready var tile_at_cursor: Sprite = $Middle/TileAtCursor
onready var tiles_panel = $TilesPanel
onready var grid_lines = $GridLines

onready var current_layer_label: Label = $HUD/VBoxContainer/CurrentLayer
onready var grid_offset_label: Label = $HUD/VBoxContainer/GridOffset
onready var cell_position_label: Label = $HUD/VBoxContainer/CellPosition
onready var zoom_level_label: Label = $HUD/VBoxContainer/ZoomLevel
onready var current_angle_label: Label = $HUD/VBoxContainer/CurrentAngle

var tilemap: TileMap = null
var current_tile := "wall"
var painting := false
var erasing := false
var scrolling := false
var zooming := false
var tileset: TileSet = null
var current_zoom: float = 1
var offset := Vector2.ZERO
var current_tool = ToolMode.PENCIL
var current_layer: int = MapLayer.BACKGROUND
var current_tile_rotation := 0

var grid_bounds_coefficient = 1
onready var cell_size = background_tilemap.cell_size * background_tilemap.scale
onready var grid_size = get_viewport_rect().size / cell_size
onready var grid_width = grid_size.x
onready var grid_height = grid_size.y
onready var grid_total_width = grid_width * (grid_bounds_coefficient * 2 + 1)
onready var grid_total_height = grid_height * (grid_bounds_coefficient * 2 + 1)
onready var grid_bounds = Rect2(-grid_width * grid_bounds_coefficient, -grid_height * grid_bounds_coefficient, grid_width * (grid_bounds_coefficient * 2 + 1), grid_height * (grid_bounds_coefficient * 2 + 1))
onready var tilemaps = [background_tilemap, middleground_tilemap, foreground_tilemap]
onready var tilemap_colors = [background_tilemap.modulate, middleground_tilemap.modulate, foreground_tilemap.modulate]

func _ready():
    # Configure grid lines
    grid_lines.grid_bounds = grid_bounds
    grid_lines.grid_width = grid_width
    grid_lines.grid_height = grid_height
    grid_lines.cell_size = cell_size

    set_current_tilemap_layer(current_layer)
    tileset = tilemap.tile_set

    _update_tile_at_cursor()
    update()

    tiles_panel.connect("tile_selected", self, "set_current_tile")
    tiles_panel.connect("tool_selected", self, "set_current_tool")

func _update_tile_at_cursor():
    var tile_idx = tileset.find_tile_by_name(current_tile)
    var tile_region = tileset.tile_get_region(tile_idx)
    tile_at_cursor.region_rect = tile_region

func _process(_delta: float):
    # Lock offset
    offset.x = clamp(
        offset.x,
        -grid_width * grid_bounds_coefficient * cell_size.x * current_zoom,
        grid_width * grid_bounds_coefficient * 2 * cell_size.x * current_zoom
    )
    offset.y = clamp(
        offset.y,
        -grid_height * grid_bounds_coefficient * cell_size.y * current_zoom,
        grid_height * grid_bounds_coefficient * 2 * cell_size.y * current_zoom
    )
    grid_lines.offset = offset

    for tm in tilemaps:
        tm.position = offset
        tm.scale = 2 * Vector2(current_zoom, current_zoom)

    var mouse_pos = get_local_mouse_position()
    var map_tile_pos = _get_map_tile_pos(mouse_pos)
    var pos_in_bounds = _tile_pos_in_bounds(map_tile_pos)
    if pos_in_bounds:
        if painting:
            paint_tile_with_current(map_tile_pos)
        elif erasing:
            erase_tile(map_tile_pos)

    tile_at_cursor.scale = Vector2(2 * current_zoom, 2 * current_zoom)
    grid_offset_label.text = "Grid offset: (%d, %d)" % [offset.x, offset.y]
    cell_position_label.text = "Cell position: (%d, %d)" % [map_tile_pos.x, map_tile_pos.y]
    zoom_level_label.text = "Zoom level: x%f" % current_zoom
    current_angle_label.text = "Current angle: %d°" % current_tile_rotation

    tile_at_cursor.rotation_degrees = current_tile_rotation
    if pos_in_bounds:
        tile_at_cursor.visible = true
        tile_at_cursor.position = _get_placeholder_pos(mouse_pos)
    else:
        tile_at_cursor.visible = false

func _zoom_at_mouse_pos(mouse_pos: Vector2, coef: float) -> void:
    # TODO: handle offset
    _set_current_zoom(current_zoom * coef)

func _get_map_tile_pos(mouse_pos: Vector2) -> Vector2:
    return (tilemap.world_to_map((mouse_pos - offset) * 1 / current_zoom) / 2).floor()

func _get_placeholder_pos(mouse_pos: Vector2) -> Vector2:
    return ((tilemap.map_to_world(_get_map_tile_pos(mouse_pos)) * 2) + tilemap.cell_size) * current_zoom + offset

func _tile_pos_in_bounds(pos: Vector2) -> bool:
    return grid_bounds.has_point(pos)

func paint_tile_with_current(pos: Vector2):
    var tile_idx = tileset.find_tile_by_name(current_tile)
    var params = SxTileMap.rotation_degrees_to_params(current_tile_rotation)
    tilemap.set_cellv(pos, tile_idx, params.flip_x, params.flip_y, params.transpose)

func erase_tile(pos: Vector2):
    tilemap.set_cellv(pos, -1)

func set_current_tile(tile_name: String) -> void:
    current_tile = tile_name
    _update_tile_at_cursor()

func _get_layer_color(map_layer: int, target_layer: int) -> Color:
    # If current layer is above, no need for transparency
    if target_layer > map_layer:
        return tilemap_colors[map_layer]
    else:
        return SxColor.with_alpha_f(tilemap_colors[map_layer], 0.25)

func set_current_tilemap_layer(map_layer: int) -> void:
    background_tilemap.modulate = _get_layer_color(MapLayer.BACKGROUND, map_layer)
    middleground_tilemap.modulate = _get_layer_color(MapLayer.MIDDLEGROUND, map_layer)
    foreground_tilemap.modulate = _get_layer_color(MapLayer.FOREGROUND, map_layer)

    current_layer = map_layer
    tilemap = _get_tilemap_layer(map_layer)
    tilemap.modulate = tilemap_colors[current_layer]

    current_layer_label.text = "Current layer: %s" % _map_layer_to_string(map_layer)

func toggle_ui():
    tiles_panel.visible = !tiles_panel.visible

func _map_layer_to_string(map_layer: int) -> String:
    if map_layer == MapLayer.BACKGROUND:
        return "Background"
    elif map_layer == MapLayer.MIDDLEGROUND:
        return "Middleground"
    else:
        return "Foreground"

func _get_tilemap_layer(map_layer: int) -> TileMap:
    if map_layer == MapLayer.BACKGROUND:
        return background_tilemap
    elif map_layer == MapLayer.MIDDLEGROUND:
        return middleground_tilemap
    else:
        return foreground_tilemap

func set_current_tool(tool_mode: int) -> void:
    if tool_mode == ToolMode.ROTATE:
        _rotate_current_tile()
    else:
        current_tool = tool_mode

func _rotate_current_tile() -> void:
    current_tile_rotation = (current_tile_rotation + 90) % 360

func _unhandled_input(event: InputEvent):
    if event is InputEventMouseButton:
        var event_btn: InputEventMouseButton = event
        if event_btn.button_index == BUTTON_LEFT:
            if current_tool == ToolMode.PENCIL:
                painting = event_btn.pressed
                zooming = false
                scrolling = false
            elif current_tool == ToolMode.MOVE:
                painting = false
                zooming = false
                scrolling = event_btn.pressed
            elif current_tool == ToolMode.ZOOM:
                zooming = event_btn.pressed
                painting = false
                scrolling = false
        elif event_btn.button_index == BUTTON_RIGHT:
            erasing = event_btn.pressed
        elif event_btn.button_index == BUTTON_MIDDLE:
            scrolling = event_btn.pressed
        elif event_btn.button_index == BUTTON_WHEEL_UP:
            _zoom_at_mouse_pos(event_btn.position, 1.05)
        elif event_btn.button_index == BUTTON_WHEEL_DOWN:
            _zoom_at_mouse_pos(event_btn.position, 0.95)

    elif event is InputEventMouseMotion:
        var event_mot: InputEventMouseMotion = event
        if scrolling:
            _set_offset(offset + event_mot.relative)
        elif zooming:
            if event_mot.relative.y > 0:
                _zoom_at_mouse_pos(event_mot.position, 1.05)
            elif event_mot.relative.y < 0:
                _zoom_at_mouse_pos(event_mot.position, 0.95)

    elif event is InputEventKey:
        var event_key: InputEventKey = event
        if event_key.pressed && event_key.scancode == KEY_C:
            _reset_position()
        elif event_key.pressed && event_key.scancode == KEY_R:
            _rotate_current_tile()
        elif event_key.pressed && event_key.scancode == KEY_F1:
            set_current_tilemap_layer(MapLayer.BACKGROUND)
        elif event_key.pressed && event_key.scancode == KEY_F2:
            set_current_tilemap_layer(MapLayer.MIDDLEGROUND)
        elif event_key.pressed && event_key.scancode == KEY_F3:
            set_current_tilemap_layer(MapLayer.FOREGROUND)

    _set_current_zoom(clamp(current_zoom, 0.2, 2.0))

func _reset_position():
    _set_current_zoom(1)
    _set_offset(Vector2.ZERO)

func _set_offset(off: Vector2) -> void:
    offset = off
    grid_lines.offset = off

func _set_current_zoom(zoom: float) -> void:
    current_zoom = zoom
    grid_lines.current_zoom = zoom
