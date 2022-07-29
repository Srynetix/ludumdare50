extends Area2D
class_name ExitDoor

export var initial_opened := false

var is_exit := true
var opened := false setget _set_opened

onready var _animation_player := $AnimationPlayer as AnimationPlayer

# Activate the door.
func activate() -> void:
    opened = initial_opened

func _set_opened(value: bool) -> void:
    if opened == value:
        return

    opened = value
    if opened:
        _animation_player.play("opened")
    else:
        _animation_player.play("closed")