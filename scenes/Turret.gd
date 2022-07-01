extends Area2D
class_name Turret

var max_hits := 3
var bullet_target: Node
var firing := false
var fire_rate := 1.0

onready var gun: Node2D = $Gun
onready var muzzle: Position2D = $Gun/Muzzle
onready var timer: Timer = $Timer
onready var animation_player: AnimationPlayer = $AnimationPlayer
onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _target_node: Node
var _stopped := false
var _exploded := false
var _current_hit := 0

func _ready() -> void:
    connect("body_entered", self, "_on_body_entered")

    timer.wait_time = fire_rate
    timer.connect("timeout", self, "_on_timer_timeout")

func _process(_delta: float) -> void:
    if is_ready():
        _aim_target_node()

func is_ready() -> bool:
    return !_stopped && !_exploded

func track_node(node: Node2D) -> void:
    _target_node = node

func untrack() -> void:
    _target_node = null

func hit() -> void:
    _current_hit += 1

    audio_stream_player.pitch_scale = rand_range(0.5, 1.5)
    audio_stream_player.play()

    if _current_hit >= max_hits:
        explode()

func explode() -> void:
    _exploded = true
    collision_shape.set_deferred("disabled", true)
    animation_player.play("explode")

func fire() -> void:
    var bullet: Bullet = GameLoadCache.instantiate_scene("Bullet")
    var trajectory = Vector2.RIGHT.rotated(gun.rotation)
    var bullet_initial_velocity = trajectory * 200
    bullet.hurt_player = true
    bullet.max_bounces = 0
    bullet.position = muzzle.global_position
    bullet.initial_velocity = bullet_initial_velocity

    if bullet_target != null:
        bullet_target.add_child(bullet)
    else:
        get_parent().add_child(bullet)

func activate() -> void:
    start()

func start() -> void:
    _stopped = false
    timer.start()

func stop() -> void:
    _stopped = true
    _target_node = null
    timer.stop()

func _aim_target_node() -> void:
    if _target_node != null:
        var dir = position.direction_to(_target_node.position)
        gun.rotation = dir.angle()
    else:
        gun.rotation = 0

func _on_timer_timeout() -> void:
    if _target_node != null && is_ready():
        fire()

func _on_body_entered(body: PhysicsBody2D) -> void:
    if body is Bullet:
        var bullet: Bullet = body
        bullet.destroy()
        hit()