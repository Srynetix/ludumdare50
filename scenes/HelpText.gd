extends CanvasLayer
class_name HelpText

signal shown()

export(String, MULTILINE) var text := ""

onready var label := $MarginContainer/SxFadingRichTextLabel as SxFadingRichTextLabel

func _ready() -> void:
    label.connect("shown", self, "_on_label_shown")

func _on_label_shown() -> void:
    emit_signal("shown")

func fade_in() -> void:
    label.update_text(text)
    label.fade_in()