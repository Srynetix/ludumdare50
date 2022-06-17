extends SxLoadCache

func load_resources():
    var logger = SxLog.get_logger("SxLoadCache")
    logger.set_max_log_level(SxLog.LogLevel.INFO)

    var level_count: int = 10

    # Scenes
    store_scene("SparklesFX", "res://scenes/SparklesFX.tscn");
    store_scene("Destructible", "res://scenes/Destructible.tscn");
    store_scene("ExplosionFX", "res://scenes/ExplosionFX.tscn");
    store_scene("ExitDoor", "res://scenes/ExitDoor.tscn");
    store_scene("TimeBomb", "res://scenes/TimeBomb.tscn");
    store_scene("Glass", "res://scenes/Glass.tscn");
    store_scene("Spikes", "res://scenes/Spikes.tscn");
    store_scene("PushButton", "res://scenes/PushButton.tscn");
    store_scene("Player", "res://scenes/Player.tscn");
    store_scene("Turret", "res://scenes/Turret.tscn");
    store_scene("Bullet", "res://scenes/Bullet.tscn");

    # Music
    store_resource("track1", "res://assets/music/track1.ogg")
    store_resource("track2", "res://assets/music/track2.ogg")
    store_resource("track3", "res://assets/music/track3.ogg")
    store_resource("track4", "res://assets/music/track4.ogg")
    store_resource("track5", "res://assets/music/track5.ogg")

    # Screens
    store_scene("BootScreen", "res://screens/Boot.tscn")
    store_scene("GameScreen", "res://screens/Game.tscn")
    store_scene("GameOverScreen", "res://screens/GameOver.tscn")
    store_scene("GameOverGoodScreen", "res://screens/GameOverGood.tscn")
    store_scene("TitleScreen", "res://screens/Title/Title.tscn")
    store_scene("OptionsScreen", "res://screens/Options/Options.tscn")
    store_scene("LevelSelectorScreen", "res://screens/LevelSelector/LevelSelector.tscn")
    store_scene("EditorScreen", "res://screens/LevelEditor/LevelEditor.tscn")

    # Levels
    for i in range(level_count + 1):
        store_scene(
            "Level%02d" % i,
            "res://levels/Level%02d.tscn" % i
        )

    store_scene("LevelEnd", "res://levels/LevelEnd.tscn")
