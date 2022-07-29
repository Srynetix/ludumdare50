extends Control

onready var backbutton := $MarginContainer/VBoxContainer/HBoxContainer/Button as Button
onready var tab_container := $"MarginContainer/VBoxContainer/TabContainer" as TabContainer
onready var template_tab := $"MarginContainer/VBoxContainer/TabContainer/Template" as ScrollContainer

var _level_card := preload("res://screens/LevelSelector/LevelCard.tscn") as PackedScene

func _ready() -> void:
    backbutton.connect("pressed", self, "_on_back_pressed")

    var collection_folders = LevelCollection.scan_collection_names()
    for folder in collection_folders:
        var collection = LevelCollection.new()
        collection.load_system_collection(folder)
        _prepare_collection_levels(collection)

    _prepare_user_levels()

    # Remove template
    template_tab.queue_free()

func _prepare_collection_levels(collection: LevelCollection):
    # First, clone the Template tab
    var collection_tab = template_tab.duplicate()
    collection_tab.name = collection.collection_name
    tab_container.add_child(collection_tab)

    # Remove placeholder cards
    var levels_container := collection_tab.get_node("Levels") as VBoxContainer
    for child in levels_container.get_children():
        child.queue_free()

    # Now, render levels
    var max_level = GameData.get_max_level(collection.collection_folder)
    for x in range(min(max_level + 1, len(collection.levels))):
        var level_item = collection.levels[x]
        var card = _level_card.instance()
        levels_container.add_child(card)

        card.level_name = level_item.level_name
        card.level_author = level_item.level_author
        card.connect("pressed", self, "_on_level_pressed", [collection, x])

func _prepare_user_levels():
    # First, clone the Template tab
    var collection_tab = template_tab.duplicate()
    collection_tab.name = "User Levels"
    tab_container.add_child(collection_tab)

    # Remove placeholder cards
    var levels_container := collection_tab.get_node("Levels") as VBoxContainer
    for child in levels_container.get_children():
        child.queue_free()

    var collection = LevelCollection.new()
    collection.load_user_collection()

    for x in range(len(collection.levels)):
        var level_item = collection.levels[x]
        var card = _level_card.instance()
        levels_container.add_child(card)

        card.level_name = level_item.level_name
        card.level_author = level_item.level_author
        card.connect("pressed", self, "_on_level_pressed", [collection, x])

func _on_back_pressed() -> void:
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "TitleScreen")

func _on_level_pressed(collection: LevelCollection, level: int) -> void:
    GameData.set_last_level(collection.collection_folder, level)
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "GameScreen")
