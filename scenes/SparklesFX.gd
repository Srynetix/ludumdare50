extends CPUParticles2D
class_name SparklesFX

func _ready() -> void:
    one_shot = true

    yield(get_tree().create_timer(1.0), "timeout")
    queue_free()