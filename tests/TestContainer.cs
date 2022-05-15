using Godot;
using SxGD;

public class TestContainer : Node
{
    public override void _Ready()
    {
        var track1 = LoadCache.GetInstance().LoadResource<AudioStreamOGGVorbis>("track2");
        GlobalMusicPlayer.Instance.Play(track1);
    }
}
