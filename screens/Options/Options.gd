extends Control

onready var effects_volume = $"MarginContainer/VBoxContainer/Margin/VBoxContainer/EffectsVolume"
onready var music_volume = $"MarginContainer/VBoxContainer/Margin/VBoxContainer/MusicVolume"
onready var effects_bus_idx: int = AudioServer.get_bus_index("Effects")
onready var music_bus_idx: int = AudioServer.get_bus_index("Music")
onready var effects_test: AudioStreamPlayer = $EffectsTest

func _ready():
    effects_volume.value = _db_to_percent(GameData.effects_volume)
    music_volume.value = _db_to_percent(GameData.music_volume)
    effects_volume.connect("value_changed", self, "_on_effects_volume_changed")
    music_volume.connect("value_changed", self, "_on_music_volume_changed")

func _percent_to_db(percent: int) -> int:
    # TODO: Use linear2db
    if percent == 0:
        return -100
    return int(SxMath.map(percent, 0, 100, -24, 0))

func _db_to_percent(db: int) -> int:
    if db == -100:
        return 0
    return int(SxMath.map(db, -24, 0, 0, 100))

func _on_effects_volume_changed(value: int) -> void:
    GameData.effects_volume = _percent_to_db(value)
    effects_test.play()

func _on_music_volume_changed(value: int) -> void:
    GameData.music_volume = _percent_to_db(value)

func go_back():
    GameData.persist_to_disk()
    GameSceneTransitioner.fade_to_cached_scene(GameLoadCache, "TitleScreen")
