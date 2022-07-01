extends Node2D
class_name Level

const Direction = SxFXCamera.Direction

signal success()
signal restart()

export var level_author := ""
export var level_name := ""
export var bomb_time := 30
export(String, MULTILINE) var help_text := "Hello."
export var wait_for_help_text := false
export var turret_fire_rate := 1.0
export var lock_camera := false
export var editor_mode := false

onready var areas_target: Node = $Areas
onready var fx_target: Node = $FX
onready var players_target: Node = $Players
onready var background_tilemap: TileMap = $Background
onready var tilemap: TileMap = $Middleground
onready var foreground_tilemap: TileMap = $Foreground
onready var level_hud: LevelHUD = $LevelHUD
onready var success_fx: AudioStreamPlayer = $SuccessFX
onready var camera: SxFXCamera = $Camera

var initial_background_tile_data := PoolIntArray()
var initial_middleground_tile_data := PoolIntArray()
var initial_foreground_tile_data := PoolIntArray()

var _players := Array()
var _time_bombs := Array()
var _exit_doors := Array()
var _push_buttons := Array()
var _turrets := Array()
var _finished := false
var _animating_camera := false
var _frozen_bomb_count := 0

func _ready() -> void:
    level_hud.connect("level_ready", self, "_activate")
    level_hud.set_level_data(level_name, level_author, help_text, wait_for_help_text)

    if len(initial_background_tile_data) > 0:
        SxTileMap.apply_dump(background_tilemap, initial_background_tile_data)

    if len(initial_middleground_tile_data) > 0:
        SxTileMap.apply_dump(tilemap, initial_middleground_tile_data)

    if len(initial_foreground_tile_data) > 0:
        SxTileMap.apply_dump(foreground_tilemap, initial_foreground_tile_data)

    call_deferred("_spawn_tiles")
    _prepare_camera()

func _process(_delta: float) -> void:
    if !_finished:
        if len(_players) > 0:
            var player: Player = _players[0]
            _camera_follow_player(player)
            _update_turrets()

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

func _end_mechanisms() -> void:
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
    if !editor_mode:
        GameData.increment("deaths")
        GameData.persist_to_disk()

    level_hud.play_animation("game_over")
    yield(get_tree().create_timer(1), "timeout")

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
            tile.connect("frozen", self, "_on_bomb_frozen", [tile])
            tile.connect("unfrozen", self, "_on_bomb_unfrozen", [tile])
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
    _end_mechanisms()

    level_hud.play_animation("win")
    success_fx.play()

    yield(get_tree().create_timer(1), "timeout")

    emit_signal("success")

func _on_player_dead(player: Player) -> void:
    _end_mechanisms()
    _show_explosion(player.global_position)
    _game_over()

func _show_explosion(position: Vector2) -> void:
    var explosion: ExplosionFX = GameLoadCache.instantiate_scene("ExplosionFX")
    fx_target.add_child(explosion)
    explosion.position = position
    explosion.explode()

func _on_bomb_explosion(bomb: TimeBomb) -> void:
    _end_mechanisms()
    yield(_zoom_on_position(bomb.global_position), "completed")

    _show_explosion(bomb.global_position)
    _game_over()

func _on_bomb_frozen(_bomb: TimeBomb) -> void:
    _frozen_bomb_count += 1

    for node in get_tree().get_nodes_in_group("turret"):
        var turret: Turret = node
        turret.stop()

    for node in get_tree().get_nodes_in_group("bullet"):
        var bullet: Bullet = node
        if bullet.hurt_player:
            bullet.freeze()

func _on_bomb_unfrozen(_bomb: TimeBomb) -> void:
    _frozen_bomb_count -= 1

    if _frozen_bomb_count == 0:
        for node in get_tree().get_nodes_in_group("turret"):
            var turret: Turret = node
            turret.start()

        for node in get_tree().get_nodes_in_group("bullet"):
            var bullet: Bullet = node
            if bullet.hurt_player:
                bullet.unfreeze()

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

func _camera_follow_player(player: Player) -> void:
    if _animating_camera:
        return

    _animating_camera = true
    var position = player.global_position

    if lock_camera:
        if position.x > camera.limit_right:
            yield(camera.viewport_scroll(Vector2(camera.limit_left, camera.limit_top), Direction.RIGHT), "completed")
        elif position.x < camera.limit_left:
            yield(camera.viewport_scroll(Vector2(camera.limit_left, camera.limit_top), Direction.LEFT), "completed")
        elif position.y > camera.limit_bottom:
            yield(camera.viewport_scroll(Vector2(camera.limit_left, camera.limit_top), Direction.DOWN), "completed")
        elif position.y < camera.limit_top:
            yield(camera.viewport_scroll(Vector2(camera.limit_left, camera.limit_top), Direction.UP), "completed")

    camera.global_position = position
    _animating_camera = false

func _update_turrets() -> void:
    var vp_size = get_viewport_rect().size
    var vp_half_size = vp_size / 2
    var vp_dist = vp_size.length_squared()

    for node in _turrets:
        var turret: Turret = node
        if turret.is_ready():
            var nearest_player = null
            var nearest_distance = INF
            for pnode in _players:
                var player: Player = pnode
                # Two scanning mode, if camera is locked or not
                if lock_camera:
                    # Only scan if player is in the same space than the turret
                    var player_space = ((player.global_position - vp_half_size) / vp_size).round()
                    var turret_space = ((turret.global_position - vp_half_size) / vp_size).round()
                    if player_space != turret_space:
                        continue

                # Only scan if player is in the same space than the turret
                var dist = turret.global_position.distance_squared_to(player.global_position)
                if dist < vp_dist && dist < nearest_distance:
                    nearest_distance = dist
                    nearest_player = player

            if nearest_player == null:
                turret.untrack()
            else:
                turret.track_node(nearest_player)
