extends Panel

export var tileset: TileSet

enum ToolMode {
    PENCIL,
    ERASER,
    MOVE,
    ZOOM,
    ROTATE
}

enum MapLayer {
    BACKGROUND = 0,
    MIDDLEGROUND,
    FOREGROUND
}

signal tile_selected(tile_name)
signal tool_selected(tool_mode)
signal layer_selected(map_layer)

onready var tile_container: HBoxContainer = $MarginContainer/HBoxContainer/Tiles/HBoxContainer
onready var tool_pencil: Button = $MarginContainer/HBoxContainer/Tools/HBoxContainer/Pencil
onready var tool_eraser: Button = $MarginContainer/HBoxContainer/Tools/HBoxContainer/Eraser
onready var tool_move: Button = $MarginContainer/HBoxContainer/Tools/HBoxContainer/Move
onready var tool_zoom: Button = $MarginContainer/HBoxContainer/Tools/HBoxContainer/Zoom
onready var tool_rotate: Button = $MarginContainer/HBoxContainer/Tools/HBoxContainer/Rotate
onready var grid_layer: MenuButton = $MarginContainer/HBoxContainer/Grid/HBoxContainer/Layer

var selected_tile: TextureButton = null
var selected_tool: Button = null
var selected_layer: int = MapLayer.MIDDLEGROUND

const tile_size = 24

func _ready():
    var first_tile = true

    for tile_idx in tileset.get_tiles_ids():
        var tile_name = tileset.tile_get_name(tile_idx)
        var sprite = TextureButton.new()
        var sprite_texture = AtlasTexture.new()
        sprite_texture.atlas = tileset.tile_get_texture(tile_idx)
        sprite_texture.region = tileset.tile_get_region(tile_idx)
        sprite.texture_normal = sprite_texture
        sprite.stretch_mode = TextureRect.STRETCH_SCALE
        sprite.expand = true
        sprite.rect_min_size = Vector2(tile_size, tile_size)
        sprite.rect_size = Vector2(tile_size, tile_size)
        sprite.hint_tooltip = tile_name
        sprite.size_flags_horizontal = SIZE_SHRINK_CENTER
        sprite.size_flags_vertical = SIZE_SHRINK_CENTER
        sprite.mouse_filter = MOUSE_FILTER_PASS
        sprite.connect("pressed", self, "_on_tile_pressed", [ sprite, tile_name ])
        tile_container.add_child(sprite)

        if first_tile:
            call_deferred("_on_tile_pressed", sprite, tile_name)
            first_tile = false

    tool_pencil.connect("pressed", self, "_on_tool_pressed", [ tool_pencil, ToolMode.PENCIL ])
    tool_eraser.connect("pressed", self, "_on_tool_pressed", [ tool_eraser, ToolMode.ERASER ])
    tool_move.connect("pressed", self, "_on_tool_pressed", [ tool_move, ToolMode.MOVE ])
    tool_zoom.connect("pressed", self, "_on_tool_pressed", [ tool_zoom, ToolMode.ZOOM ])
    tool_rotate.connect("pressed", self, "_on_tool_pressed", [ tool_rotate, ToolMode.ROTATE ])
    grid_layer.get_popup().connect("id_pressed", self, "_on_layer_selected")
    grid_layer.get_popup().set("custom_fonts/font", grid_layer.get("custom_fonts/font"))
    grid_layer.text = map_layer_to_string(selected_layer)

    call_deferred("_on_tool_pressed", tool_pencil, ToolMode.PENCIL)

func _on_tile_pressed(tile: TextureButton, tile_name: String) -> void:
    if selected_tile != null:
        selected_tile.modulate = Color.white
    selected_tile = tile
    selected_tile.modulate = SxColor.with_alpha_f(Color.lightgray, 0.5)

    emit_signal("tile_selected", tile_name)

func _on_tool_pressed(btn: Button, tool_mode: int) -> void:
    if btn != tool_rotate:
        if selected_tool != null:
            selected_tool.modulate = Color.white
        selected_tool = btn
        selected_tool.modulate = SxColor.with_alpha_f(Color.lightgray, 0.5)

    emit_signal("tool_selected", tool_mode)

func _on_layer_selected(item_id: int) -> void:
    selected_layer = item_id
    grid_layer.text = map_layer_to_string(item_id)

    for idx in range(grid_layer.get_popup().get_item_count()):
        grid_layer.get_popup().set_item_checked(idx, false)
    grid_layer.get_popup().set_item_checked(item_id, true)

    emit_signal("layer_selected", item_id)

func map_layer_to_string(map_layer: int) -> String:
    if map_layer == MapLayer.BACKGROUND:
        return "Background"
    elif map_layer == MapLayer.MIDDLEGROUND:
        return "Middleground"
    return "Foreground"

func _unhandled_input(event):
    if event is InputEventKey:
        var event_key: InputEventKey = event
        if event_key.pressed && event_key.scancode == KEY_R:
            _on_tool_pressed(tool_rotate, ToolMode.ROTATE)
        elif event_key.pressed && event_key.scancode == KEY_E:
            _on_tool_pressed(tool_eraser, ToolMode.ERASER)
        elif event_key.pressed && event_key.scancode == KEY_M:
            _on_tool_pressed(tool_rotate, ToolMode.MOVE)
        elif event_key.pressed && event_key.scancode == KEY_Z:
            _on_tool_pressed(tool_rotate, ToolMode.ZOOM)
        elif event_key.pressed && event_key.scancode == KEY_P:
            _on_tool_pressed(tool_rotate, ToolMode.PENCIL)
        elif event_key.pressed && event_key.scancode == KEY_F1:
            _on_layer_selected(MapLayer.BACKGROUND)
        elif event_key.pressed && event_key.scancode == KEY_F2:
            _on_layer_selected(MapLayer.MIDDLEGROUND)
        elif event_key.pressed && event_key.scancode == KEY_F3:
            _on_layer_selected(MapLayer.FOREGROUND)
