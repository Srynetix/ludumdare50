extends Control

onready var effects_volume := $"MarginContainer/VBoxContainer/Margin/VBoxContainer/EffectsVolume" as OptionSlider
onready var music_volume := $"MarginContainer/VBoxContainer/Margin/VBoxContainer/MusicVolume" as OptionSlider
onready var resolution := $"MarginContainer/VBoxContainer/Margin/VBoxContainer/Resolution/OptionButton" as OptionButton
onready var effects_bus_idx := AudioServer.get_bus_index("Effects")
onready var music_bus_idx := AudioServer.get_bus_index("Music")
onready var effects_test := $EffectsTest as AudioStreamPlayer

func _ready():
    effects_volume.value = _db_to_percent(GameData.effects_volume)
    music_volume.value = _db_to_percent(GameData.music_volume)
    effects_volume.connect("value_changed", self, "_on_effects_volume_changed")
    music_volume.connect("value_changed", self, "_on_music_volume_changed")

    if OS.get_name() in ["HTML5", "Android", "iOS"]:
        var container := resolution.get_parent() as HBoxContainer
        container.hide()
    else:
        resolution.connect("item_selected", self, "_on_resolution_changed")
        for idx in resolution.get_item_count():
            var txt = resolution.get_item_text(idx)
            if txt == GameData.resolution:
                resolution.selected = idx
                break

func _percent_to_db(percent: int) -> float:
    return linear2db(float(percent) / 100)

func _db_to_percent(db: float) -> int:
    return int(db2linear(db) * 100)

func _on_effects_volume_changed(value: int) -> void:
    GameData.effects_volume = _percent_to_db(value)
    effects_test.play()

func _on_music_volume_changed(value: int) -> void:
    GameData.music_volume = _percent_to_db(value)

func go_back():
    GameData.persist_to_disk()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "TitleScreen")

func _on_resolution_changed(idx: int) -> void:
    GameData.resolution = resolution.get_item_text(idx)