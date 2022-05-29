extends Node

func _ready() -> void:
    var track: AudioStreamOGGVorbis = GameLoadCache.load_resource("track2")
    GameGlobalMusicPlayer.play_stream(track)