using Godot;
using SxGD;

public class Boot : Control
{
    public override void _Ready()
    {
        GameData.GetInstance().Store("from_boot", true);

        var track1 = LoadCache.GetInstance().LoadResource<AudioStreamOGGVorbis>("track1");
        GlobalMusicPlayer.Instance.Play(track1);
    }

    public void LoadGame() {
        SceneTransitioner.GetInstance().FadeToScene("res://screens/Title.tscn");
    }
}
