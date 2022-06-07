extends Node2D
class_name ExplosionFX

onready var animation_player: AnimationPlayer = $AnimationPlayer

func explode() -> void:
    animation_player.play("explode")