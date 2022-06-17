extends Node

func _ready():
    var levels := Array()

    var levels_directory = Directory.new()
    levels_directory.open("res://levels")
    levels_directory.list_dir_begin()
    var file_name = levels_directory.get_next()
    while file_name != "":
        if file_name.ends_with(".tscn"):
            levels.append(file_name)
        file_name = levels_directory.get_next()

    for level_file in levels:
        var level_file_input = "res://levels/%s" % level_file
        var level_file_output = "res://assets/levels/%s" % level_file.replace(".tscn", ".lvl")
        var level = LevelFile.load_scene_level(level_file_input)
        LevelFile.save_level(level_file_output, level)

    print("OK")