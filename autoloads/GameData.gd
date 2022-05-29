extends SxGameData

func _ready():
    var logger = SxLog.get_logger("SxGameData")
    logger.set_max_log_level(SxLog.LogLevel.DEBUG)
    load_from_disk()