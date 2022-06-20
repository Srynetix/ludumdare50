tool
extends Control

signal pressed()

export var level_name: String = "Level" setget _set_level_name
export var level_author: String = "Unknown" setget _set_level_author

onready var _button: Button = $Button
onready var _level_author_label: Label = $MarginContainer/VBoxContainer/LevelAuthor
onready var _level_name_label: Label = $MarginContainer/VBoxContainer/LevelName

func _set_level_name(value: String) -> void:
    level_name = value
    if !_level_name_label:
        yield(self, "ready")
    _level_name_label.text = level_name

func _set_level_author(value: String) -> void:
    level_author = value
    if !_level_author_label:
        yield(self, "ready")
    _level_author_label.text = value

func _ready() -> void:
    _button.connect("pressed", self, "_on_button_pressed")
    _level_name_label.text = level_name
    _level_author_label.text = level_author

func _on_button_pressed() -> void:
    emit_signal("pressed")
