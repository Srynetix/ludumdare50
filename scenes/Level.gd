extends Node2D
class_name Level

signal success()
signal restart()

const LAST_LEVEL = 999999

export var level_number := 1
export var level_name := "Hello World"
export var bomb_time := 30
export(String, MULTILINE) var help_text := "Hello."
export var wait_for_help_text := false
export var turret_fire_rate := 1.0
export var lock_camera := false

onready var areas_target: Node = $Areas
onready var fx_target: Node = $FX
onready var players_target: Node = $Players
onready var tilemap: TileMap = $Middleground
onready var level_hud: LevelHUD = $LevelHUD
onready var success_fx: AudioStreamPlayer = $SuccessFX
onready var camera: SxFXCamera = $Camera

var _players := Array()
var _time_bombs := Array()
var _exit_doors := Array()
var _push_buttons := Array()
var _turrets := Array()
var _finished := false

func _ready() -> void:
    level_hud.connect("level_ready", self, "_activate")
    level_hud.set_level_data(level_number, level_name, help_text, wait_for_help_text)

    call_deferred("_spawn_tiles")
    _prepare_camera()

func _process(_delta: float) -> void:
    if !_finished:
        if len(_players) > 0:
            var player: Player = _players[0]
            camera.global_position = player.global_position

func _input(event: InputEvent) -> void:
    if event is InputEventKey:
        var key: InputEventKey = event
        if key.scancode == KEY_ENTER:
            if !GameData.has_value("from_game"):
                get_tree().reload_current_scene()

func _prepare_camera() -> void:
    var rect = tilemap.get_used_rect()
    var size = rect.position + rect.size
    var viewport_size = get_viewport_rect().size
    camera.limit_left = 0
    camera.limit_top = 0
    camera.smoothing_enabled = true

    if lock_camera:
        camera.limit_right = int(viewport_size.x)
        camera.limit_bottom = int(viewport_size.y)
    else:
        camera.limit_right = int(max(size.x * tilemap.cell_size.x * tilemap.scale.x, viewport_size.x))
        camera.limit_bottom = int(max(size.y * tilemap.cell_size.y * tilemap.scale.y, viewport_size.y))

func _activate() -> void:
    for node in _players:
        var player: Player = node
        player.detect_input = true

    for node in _time_bombs:
        var bomb: TimeBomb = node
        bomb.activate()

    for node in _exit_doors:
        var door: ExitDoor = node
        door.activate()

    for node in _turrets:
        var turret: Turret = node
        turret.activate()

func _stop_mechanisms() -> void:
    _finished = true

    for node in _players:
        var player: Player = node
        player.detect_input = false

    for node in _time_bombs:
        var bomb: TimeBomb = node
        bomb.stop()

    for node in _turrets:
        var turret: Turret = node
        turret.stop()

    for node in get_tree().get_nodes_in_group("bullet"):
        node.queue_free()

func _game_over() -> void:
    GameData.increment("deaths")
    GameData.persist_to_disk()

    level_hud.play_animation("game_over")
    yield(get_tree().create_timer(1), "timeout")

    if level_number == LAST_LEVEL:
        GameSceneTransitioner.fade_to_scene_path("res://screens/GameOver.tscn")
    else:
        emit_signal("restart")

func _spawn_tiles() -> void:
    for pos in tilemap.get_used_cells():
        var tile_idx = tilemap.get_cellv(pos)
        var tile_name = tilemap.tile_set.tile_get_name(tile_idx)

        if tile_name == "destructible":
            var tile: Destructible = GameLoadCache.instantiate_scene("Destructible")
            tile.position = (tilemap.map_to_world(pos) + tilemap.cell_size / 2) * tilemap.scale.x
            areas_target.add_child(tile)
            tilemap.set_cellv(pos, -1)

        elif tile_name == "exit":
            var tile: ExitDoor = GameLoadCache.instantiate_scene("ExitDoor")
            tile.position = (tilemap.map_to_world(pos) + tilemap.cell_size / 2 + Vector2(0, tilemap.cell_size.y / 2)) * tilemap.scale.x
            areas_target.add_child(tile)
            tilemap.set_cellv(pos, -1)
            _exit_doors.append(tile)

        elif tile_name == "start":
            var tile: ExitDoor = GameLoadCache.instantiate_scene("ExitDoor")
            tile.is_exit = false
            tile.position = (tilemap.map_to_world(pos) + tilemap.cell_size / 2 + Vector2(0, tilemap.cell_size.y / 2)) * tilemap.scale.x
            areas_target.add_child(tile)
            tilemap.set_cellv(pos, -1)
            _exit_doors.append(tile)

            var player: Player = GameLoadCache.instantiate_scene("Player")
            player.position = tile.position
            player.bullet_target = fx_target
            player.detect_input = false
            players_target.add_child(player)
            player.connect("exit", self, "_on_player_exit", [player])
            player.connect("dead", self, "_on_player_dead", [player])
            _players.append(player)

        elif tile_name == "bomb":
            var tile: TimeBomb = GameLoadCache.instantiate_scene("TimeBomb")
            tile.position = (tilemap.map_to_world(pos) + tilemap.cell_size / 2 + Vector2(tilemap.cell_size.x / 2, 0)) * tilemap.scale.x
            tile.initial_time = bomb_time
            areas_target.add_child(tile)
            tilemap.set_cellv(pos, -1)
            tile.connect("timeout", self, "_on_bomb_explosion", [tile])
            _time_bombs.append(tile)

        elif tile_name == "spikes":
            var tile: Spikes = GameLoadCache.instantiate_scene("Spikes")
            tile.rotation = SxTileMap.get_cell_rotation(tilemap, pos)
            tile.position = (tilemap.map_to_world(pos) + tilemap.cell_size / 2) * tilemap.scale.x
            areas_target.add_child(tile)
            tilemap.set_cellv(pos, -1)

        elif tile_name == "button":
            var tile: PushButton = GameLoadCache.instantiate_scene("PushButton")
            tile.rotation = SxTileMap.get_cell_rotation(tilemap, pos)
            tile.position = (tilemap.map_to_world(pos) + tilemap.cell_size / 2) * tilemap.scale.x
            areas_target.add_child(tile)
            tilemap.set_cellv(pos, -1)
            _push_buttons.append(tile)
            tile.connect("pressed", self, "_try_to_open_doors")

        elif tile_name == "glass":
            var tile: Glass = GameLoadCache.instantiate_scene("Glass")
            tile.rotation = SxTileMap.get_cell_rotation(tilemap, pos)
            tile.position = (tilemap.map_to_world(pos) + tilemap.cell_size / 2) * tilemap.scale.x
            areas_target.add_child(tile)
            tilemap.set_cellv(pos, -1)

        elif tile_name == "turret":
            var tile: Turret = GameLoadCache.instantiate_scene("Turret")
            tile.fire_rate = turret_fire_rate
            tile.rotation = SxTileMap.get_cell_rotation(tilemap, pos)
            tile.position = (tilemap.map_to_world(pos) + tilemap.cell_size / 2) * tilemap.scale.x
            areas_target.add_child(tile)
            tilemap.set_cellv(pos, -1)
            _turrets.append(tile)

func _on_player_exit(_player: Player) -> void:
    _stop_mechanisms()

    level_hud.play_animation("win")
    success_fx.play()

    yield(get_tree().create_timer(1), "timeout")

    if level_number == LAST_LEVEL:
        GameSceneTransitioner.fade_to_scene_path("res://screens/GameOverGood.tscn")
    else:
        emit_signal("success")

func _on_player_dead(player: Player) -> void:
    var explosion: ExplosionFX = GameLoadCache.instantiate_scene("ExplosionFX")
    fx_target.add_child(explosion)

    explosion.position = player.position
    explosion.explode()

    _stop_mechanisms()
    _game_over()

func _on_bomb_explosion(bomb: TimeBomb) -> void:
    _stop_mechanisms()
    yield(_zoom_on_position(bomb.global_position), "completed")

    var explosion = GameLoadCache.instantiate_scene("ExplosionFX")
    fx_target.add_child(explosion)
    explosion.position = bomb.position
    explosion.explode()

    _game_over()

func _try_to_open_doors() -> void:
    for node in _push_buttons:
        var btn: PushButton = node
        if !btn.is_pressed:
            return

    for node in _exit_doors:
        var door: ExitDoor = node
        if door.is_exit && !door.opened:
            door.opened = true

func _zoom_on_position(position: Vector2) -> void:
    camera.limit_left = -1000000
    camera.limit_right = 1000000
    camera.limit_top = -1000000
    camera.limit_bottom = 1000000
    camera.smoothing_enabled = false
    yield(camera.tween_to_position(position, 0.5, 0.5), "completed")
