using Godot;
using SxGD;

public class GameLoadCache : LoadCache
{
    public override void Initialize() {
        int levelCount = 7;

        // Scenes
        StoreScene<SparklesFX>("res://scenes/SparklesFX.tscn");
        StoreScene<Destructible>("res://scenes/Destructible.tscn");
        StoreScene<Bullet>("res://scenes/Bullet.tscn");
        StoreScene<Player>("res://scenes/Player.tscn");
        StoreScene<ExitDoor>("res://scenes/ExitDoor.tscn");
        StoreScene<TimeBomb>("res://scenes/TimeBomb.tscn");
        StoreScene<Spikes>("res://scenes/Spikes.tscn");
        StoreScene<PushButton>("res://scenes/PushButton.tscn");
        StoreScene<Glass>("res://scenes/Glass.tscn");
        StoreScene<Turret>("res://scenes/Turret.tscn");
        StoreScene<ExplosionFX>("res://scenes/ExplosionFX.tscn");

        // Music
        StoreResource<AudioStreamOGGVorbis>("track1", "res://assets/music/track1.ogg");
        StoreResource<AudioStreamOGGVorbis>("track2", "res://assets/music/track2.ogg");
        StoreResource<AudioStreamOGGVorbis>("track3", "res://assets/music/track3.ogg");
        StoreResource<AudioStreamOGGVorbis>("track4", "res://assets/music/track4.ogg");
        StoreResource<AudioStreamOGGVorbis>("track5", "res://assets/music/track5.ogg");

        // Levels
        for (int i = 0; i <= levelCount; ++i) {
            StoreScene($"Level{i:00}", $"res://levels/Level{i:00}.tscn");
        }
        StoreScene($"LevelEnd", $"res://levels/LevelEnd.tscn");
    }
}
