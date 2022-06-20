tool
extends HBoxContainer

signal value_changed(value)

export var value: int = 75 setget _set_value
export var option_name: String = "Option name" setget _set_option_name

onready var name_label: Label = $Name
onready var slider: HSlider = $Slider
onready var value_label: Label = $Value

func _ready():
    slider.connect("value_changed", self, "_on_slider_update")
    _set_option_name(option_name)
    _set_value(value)

func _on_slider_update(v: float) -> void:
    value_label.text = "%d%%" % v
    emit_signal("value_changed", v)

func _set_value(v: int) -> void:
    value = v
    if !slider:
        yield(self, "ready")
    slider.value = v
    value_label.text = "%d%%" % v

func _set_option_name(v: String) -> void:
    option_name = v
    if !name_label:
        yield(self, "ready")
    name_label.text = v
