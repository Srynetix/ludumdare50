extends KinematicBody2D
class_name Destructible

var max_hits := 3

onready var sprite: Sprite = $Sprite
onready var shader_material: ShaderMaterial = sprite.material
onready var explosion_fx: CPUParticles2D = $ExplosionFX
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var _current_hit := 0

func hit() -> void:
    _current_hit += 1

    audio_stream_player.pitch_scale = rand_range(0.5, 1.5)
    audio_stream_player.play()

    if _current_hit >= max_hits:
        explode()

func explode() -> void:
    sprite.visible = false

    collision_shape.set_deferred("disabled", true)
    explosion_fx.emitting = true
    
    yield(get_tree().create_timer(explosion_fx.lifetime), "timeout")
    queue_free()