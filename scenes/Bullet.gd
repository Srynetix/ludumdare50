extends KinematicBody2D
class_name Bullet

var hurt_player := false
var initial_velocity := Vector2.RIGHT * 100
var max_bounces := 2

var _max_velocity := 800
var _acceleration := Vector2.ZERO
var _velocity := Vector2.ZERO
var _bounces := 0
var _frozen := false

onready var fx_player: SxGlobalAudioFxPlayer = get_node("/root/GameGlobalAudioFxPlayer")

func _ready() -> void:
    if hurt_player:
        modulate = Color.red
        set_collision_layer_bit(2, false)   # Bullets
        set_collision_layer_bit(6, true)    # EnemyBullets
        set_collision_mask_bit(7, true)     # PlayerArea

    rotation = initial_velocity.angle()
    fx_player.play("shoot")

func _physics_process(delta: float) -> void:
    if _frozen:
        return

    _acceleration = Vector2.ZERO
    _acceleration += initial_velocity
    _velocity += _acceleration
    _clamp_velocity()

    var collision = move_and_collide(_velocity * delta)
    if collision != null:
        _show_sparkles()

        var collider = collision.collider
        if collider.is_in_group("timebombs"):
            collider.freeze()
            queue_free()

        elif collider is Destructible:
            collider.hit()
            queue_free()

        initial_velocity = initial_velocity.bounce(collision.normal)
        rotation = initial_velocity.angle()
        _velocity = _velocity.bounce(collision.normal)
        _bounces += 1

    _remove_if_too_many_bounces()

func destroy() -> void:
    _show_sparkles()
    queue_free()

func freeze() -> void:
    _frozen = true

func unfreeze() -> void:
    _frozen = false

func _clamp_velocity() -> void:
    _velocity = _velocity.clamped(_max_velocity)

func _remove_if_too_many_bounces() -> void:
    if _bounces > max_bounces:
        queue_free()

func _show_sparkles() -> void:
    var sparkles = GameLoadCache.instantiate_scene("SparklesFX")
    get_parent().add_child(sparkles)
    sparkles.global_position = global_position
    fx_player.play("click")
