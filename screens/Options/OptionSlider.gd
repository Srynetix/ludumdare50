tool
extends HBoxContainer
class_name OptionSlider

signal value_changed(value)

export var value := 75 setget _set_value
export var option_name := "Option name" setget _set_option_name

onready var name_label := $Name as Label
onready var slider := $Slider as HSlider
onready var value_label := $Value as Label

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
