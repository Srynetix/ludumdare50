extends MarginContainer

onready var level_name := $Fields/LevelName/LineEdit as LineEdit
onready var level_author := $Fields/Author/LineEdit as LineEdit
onready var help_text := $Fields/HelpText/TextEdit as TextEdit
onready var bomb_time := $Fields/BombTime/SpinBox as SpinBox
onready var turret_fire_rate := $Fields/TurretFireRate/SpinBox as SpinBox
onready var wait_for_help_text := $Fields/WaitForHelpText/CheckButton as CheckButton
onready var lock_camera := $Fields/LockCamera/CheckButton as CheckButton