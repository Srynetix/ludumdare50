extends CanvasLayer
class_name LevelHUD

signal level_ready()

var _wait_for_help_text := false

onready var level_number_label: Label = $MarginContainer/LevelInfo/LevelNumber
onready var level_name_label: Label = $MarginContainer/LevelInfo/LevelName
onready var help_text: HelpText = $HelpText
onready var animation_player: AnimationPlayer = $AnimationPlayer

func set_level_data(number: int, name: String, help_text_contents: String, wait_for_help_text: bool = false) -> void:
    level_number_label.text = "Level %02d" % number
    level_name_label.text = name
    help_text.text = help_text_contents
    _wait_for_help_text = wait_for_help_text

func play_animation(anim: String):
    animation_player.play(anim)

func show_text():
    help_text.fade_in()

func send_ready_signal():
    show_text()

    if _wait_for_help_text:
        yield(help_text, "shown")

    emit_signal("level_ready")
