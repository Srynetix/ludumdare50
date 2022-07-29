tool
extends SxFullScreenDialog
class_name FullScreenExportDialog

signal closed()

onready var _clipboard_btn := $MarginContainer/VBoxContainer/Button as Button
onready var _close_btn := $MarginContainer/VBoxContainer/Close as Button
onready var _textedit := $MarginContainer/VBoxContainer/TextEdit as TextEdit

func _ready() -> void:
    _clipboard_btn.connect("pressed", self, "_copy_to_clipboard")
    _close_btn.connect("pressed", self, "_on_close")

func set_export_data(data: String) -> void:
    _textedit.text = data

func _copy_to_clipboard() -> void:
    OS.set_clipboard(_textedit.text)

func _on_close() -> void:
    emit_signal("closed")
    if autohide:
        hide()