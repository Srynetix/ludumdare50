extends KinematicBody2D
class_name Destructible

# Max hits before destruction.
var max_hits := 3

onready var _sprite := $Sprite as Sprite
onready var _explosion_fx := $ExplosionFX as CPUParticles2D
onready var _collision_shape := $CollisionShape2D as CollisionShape2D
onready var _audio_stream_player := $AudioStreamPlayer as AudioStreamPlayer

var _current_hit := 0

# Add a hit to the destructible.
func hit() -> void:
    _current_hit += 1

    _audio_stream_player.pitch_scale = rand_range(0.5, 1.5)
    _audio_stream_player.play()

    if _current_hit >= max_hits:
        _explode()

func _explode() -> void:
    _sprite.visible = false

    _collision_shape.set_deferred("disabled", true)
    _explosion_fx.emitting = true

    yield(get_tree().create_timer(_explosion_fx.lifetime), "timeout")
    queue_free()