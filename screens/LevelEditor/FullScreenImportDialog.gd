tool
extends SxFullScreenDialog
class_name FullScreenImportDialog

signal cancelled()
signal confirmed(data)

onready var _clipboard_btn := $MarginContainer/VBoxContainer/Button as Button
onready var _import_btn := $MarginContainer/VBoxContainer/HBoxContainer/Import as Button
onready var _cancel_btn := $MarginContainer/VBoxContainer/HBoxContainer/Cancel as Button
onready var _textedit := $MarginContainer/VBoxContainer/TextEdit as TextEdit

func _ready() -> void:
    _clipboard_btn.connect("pressed", self, "_copy_from_clipboard")
    _import_btn.connect("pressed", self, "_on_import")
    _cancel_btn.connect("pressed", self, "_on_cancel")

func _copy_from_clipboard() -> void:
    _textedit.text = OS.get_clipboard()

func reset_text() -> void:
    _textedit.text = ""

func _on_import() -> void:
    emit_signal("confirmed", _textedit.text)
    if autohide:
        hide()

func _on_cancel() -> void:
    emit_signal("cancelled")
    if autohide:
        hide()