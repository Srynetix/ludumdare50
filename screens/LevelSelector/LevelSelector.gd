extends Control

onready var backbutton: Button = $MarginContainer/VBoxContainer/HBoxContainer/Button
onready var levels: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/Levels

var _level_card: PackedScene = preload("res://screens/LevelSelector/LevelCard.tscn")

func _ready() -> void:
    backbutton.connect("pressed", self, "_on_back_pressed")

    # Remove placeholder cards
    for child in levels.get_children():
        child.queue_free()
        levels.remove_child(child)

    var level_data = GameData.levels
    var max_level = GameData.max_level

    for x in range(max_level + 1):
        if level_data.has(str(x)):
            var card = _level_card.instance()
            levels.add_child(card)
            card.level_id = x
            card.level_name = level_data[str(x)]
            card.connect("pressed", self, "_on_level_pressed", [x])

func _on_back_pressed() -> void:
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "TitleScreen")

func _on_level_pressed(level: int) -> void:
    GameData.last_level = level
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameScreen")
