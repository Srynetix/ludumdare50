extends CPUParticles2D
class_name SparklesFX

func _ready() -> void:
    one_shot = true

    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.autostart = true
    timer.one_shot = true
    add_child(timer)

    timer.connect("timeout", self, "queue_free")