extends Control

const BAD_HELP_TEXT = """
Hello [color=#abc123]again[/color].
You died [color=#abc123]%d[/color] times, but thanks for beating the game.
Don't forget to rate it, and let me know if you liked it.

Until next time!
"""

const GOOD_HELP_TEXT = """
ALERT ALERT, the [color=#abc123]test subject[/color] escaped!

Good for him, I have thousands like him waiting for a challenge.
"""

export var good_ending := false

onready var help_text: HelpText = $HelpText

func _ready() -> void:
    var deaths = GameData.load_value("deaths", 0)
    if good_ending:
        help_text.text = GOOD_HELP_TEXT
    else:
        help_text.text = BAD_HELP_TEXT % deaths
    help_text.fade_in()

    yield(help_text, "shown")
    GameSceneTransitioner.fade_to_scene_path("res://screens/Boot.tscn")