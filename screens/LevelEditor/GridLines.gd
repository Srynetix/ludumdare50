extends Control

var grid_bounds := Rect2()
var grid_width = 0
var grid_height = 0
var offset := Vector2(0, 0)
var cell_size := Vector2(32, 32)
var current_zoom := 1.0

func _draw() -> void:
    var zoomed_cell_size = cell_size.x * current_zoom
    var origin = offset
    var bounds = grid_bounds

    # Full grid
    for y in range(bounds.position.y, bounds.end.y + 1):
        var y_pos = y * zoomed_cell_size + origin.y
        var color = SxColor.with_alpha_f(Color.lightgray, 0.1)
        var width = 1

        if int(y) % int(grid_height) == 0:
            color = SxColor.with_alpha_f(Color.blueviolet, 0.25)
            width = 2

        draw_line(Vector2(origin.x + bounds.position.x * zoomed_cell_size, y_pos), Vector2(zoomed_cell_size * bounds.end.x + origin.x, y_pos), color, width)

    for x in range(bounds.position.x, bounds.end.x + 1):
        var x_pos = x * zoomed_cell_size + origin.x
        var color = SxColor.with_alpha_f(Color.lightgray, 0.1)
        var width = 1

        if int(x) % int(grid_width) == 0:
            color = SxColor.with_alpha_f(Color.blueviolet, 0.25)
            width = 2

        draw_line(Vector2(x_pos, origin.y + bounds.position.y * zoomed_cell_size), Vector2(x_pos, zoomed_cell_size * bounds.end.y + origin.y), color, width)

    # Center grid
    for y in range(0, grid_height + 1):
        var y_pos = y * zoomed_cell_size + origin.y
        draw_line(Vector2(origin.x, y_pos), Vector2(zoomed_cell_size * grid_width + origin.x, y_pos), SxColor.with_alpha_f(Color.blueviolet, 0.25), 2)

    for x in range(0, grid_width + 1):
        var x_pos = x * zoomed_cell_size + origin.x
        draw_line(Vector2(x_pos, origin.y), Vector2(x_pos, zoomed_cell_size * grid_height + origin.y), SxColor.with_alpha_f(Color.blueviolet, 0.25), 2)

    var width_pos = Vector2(origin.x + get_viewport_rect().size.x * current_zoom, origin.y)
    var height_pos = Vector2(origin.x, origin.y + get_viewport_rect().size.y * current_zoom)
    var color = SxColor.with_alpha_f(Color.blueviolet, 0.85)
    _draw_centered_string_with_offset(origin, Vector2(0, -20), "Origin", color)
    _draw_centered_string(origin, "x", color)
    _draw_centered_string_with_offset(width_pos, Vector2(0, -20), "Window width", color)
    _draw_centered_string(width_pos, "x", color)
    _draw_centered_string_with_offset(height_pos, Vector2(0, 20), "Window height", color)
    _draw_centered_string(height_pos, "x", color)

func _draw_centered_string(pos: Vector2, text: String, color: Color = Color.white) -> void:
    var font = get_font("font")
    var bbox = font.get_string_size(text)
    draw_string(font, Vector2(pos.x - bbox.x / 2, pos.y + bbox.y / 2), text, color)

func _draw_centered_string_with_offset(pos: Vector2, off: Vector2, text: String, color: Color = Color.white) -> void:
    var font = get_font("font")
    var bbox = font.get_string_size(text)
    draw_string(font, Vector2(pos.x - bbox.x / 2, pos.y + bbox.y / 2) + off, text, color)

func _process(_delta: float) -> void:
    update()
