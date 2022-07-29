extends Area2D
class_name PushButton

signal pressed()

var is_pressed := false

onready var animation_player := $AnimationPlayer as AnimationPlayer

func press() -> void:
    if !is_pressed:
        is_pressed = true
        animation_player.play("pressed")
        emit_signal("pressed")
