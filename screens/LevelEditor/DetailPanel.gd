extends MarginContainer

onready var level_name: LineEdit = $Fields/LevelName/LineEdit
onready var level_author: LineEdit = $Fields/Author/LineEdit
onready var help_text: TextEdit = $Fields/HelpText/TextEdit
onready var bomb_time: SpinBox = $Fields/BombTime/SpinBox
onready var turret_fire_rate: SpinBox = $Fields/TurretFireRate/SpinBox
onready var wait_for_help_text: CheckButton = $Fields/WaitForHelpText/CheckButton
onready var lock_camera: CheckButton = $Fields/LockCamera/CheckButton