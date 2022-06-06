tool
extends Control

signal pressed()

export var level_id: int = 0 setget _set_level_id
export var level_name: String = "Level" setget _set_level_name

onready var _button: Button = $Button
onready var _level_id_label: Label = $MarginContainer/VBoxContainer/LevelId
onready var _level_name_label: Label = $MarginContainer/VBoxContainer/LevelName

func _set_level_id(value: int) -> void:
    level_id = value
    _level_id_label.text = "Level %02d" % level_id

func _set_level_name(value: String) -> void:
    level_name = value
    _level_name_label.text = level_name

func _ready() -> void:
    _button.connect("pressed", self, "_on_button_pressed")

func _on_button_pressed() -> void:
    emit_signal("pressed")