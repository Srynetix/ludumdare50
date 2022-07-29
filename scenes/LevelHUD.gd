extends CanvasLayer
class_name LevelHUD

signal level_ready()

var _wait_for_help_text := false

onready var level_name_label := $MarginContainer/LevelInfo/LevelName as Label
onready var level_author_label := $MarginContainer/LevelInfo/LevelAuthor as Label
onready var help_text := $HelpText as HelpText
onready var animation_player := $AnimationPlayer as AnimationPlayer

func set_level_data(name: String, author: String, help_text_contents: String, wait_for_help_text: bool = false) -> void:
    level_name_label.text = name
    level_author_label.text = "By @%s" % author
    help_text.text = help_text_contents
    _wait_for_help_text = wait_for_help_text
    animation_player.play("show_level")

func play_animation(anim: String):
    animation_player.play(anim)

func show_text():
    help_text.fade_in()

func send_ready_signal():
    show_text()

    if _wait_for_help_text:
        yield(help_text, "shown")

    emit_signal("level_ready")
