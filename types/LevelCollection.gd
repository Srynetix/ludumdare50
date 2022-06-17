extends Node
class_name LevelCollection

const DEFAULT_COLLECTION = "ld50"
const USER_COLLECTION = "_user"

var collection_folder := ""
var collection_name := ""
var collection_author := ""
var levels := Array()

var _logger = SxLog.get_logger("LevelCollection")

func load_collection(folder_name: String):
    if folder_name == USER_COLLECTION:
        return load_user_collection()
    else:
        return load_system_collection(folder_name)

func load_system_collection(folder_name: String):
    var file = File.new()
    var file_path = "res://assets/levels/%s/collection.json" % folder_name
    var result = file.open(file_path, File.READ)
    if result != OK:
        _logger.error("Could not read collection named '%s' (error: %s)" % [folder_name, result])
        return

    var data = SxJson.read_json_from_open_file(file)
    collection_folder = folder_name
    collection_name = data["name"]
    collection_author = data["author"]
    levels = _load_levels_info(data["levels"])

func load_user_collection():
    var directory = Directory.new()
    if directory.open("user://levels") != OK:
        directory.make_dir("user://levels")
        directory.open("user://levels")

    var user_levels := Array()
    directory.list_dir_begin()
    var file_name = directory.get_next()
    while file_name != "":
        if file_name.ends_with(".lvl"):
            user_levels.append("user://levels/%s" % file_name)
        file_name = directory.get_next()

    collection_folder = USER_COLLECTION
    collection_name = "User Levels"
    collection_author = "You"
    levels = _load_levels_info(user_levels)

func _load_levels_info(levels_paths: Array) -> Array:
    var levels_info := Array()
    for path in levels_paths:
        levels_info.append(LevelFile.load_level(path))
    return levels_info

static func scan_collection_names() -> Array:
    var collections := Array()
    var directory = Directory.new()

    directory.open("res://assets/levels")
    directory.list_dir_begin()

    var _collection_name = directory.get_next()
    while _collection_name != "":
        if !_collection_name in [".", ".."]:
            collections.append(_collection_name)
        _collection_name = directory.get_next()

    return collections
