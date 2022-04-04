using Godot;
using SxGD;

public class Title : Control
{
    public override void _Ready()
    {
        // Do not try to play track1 if played from boot
        if (GameData.GetInstance().Load<bool>("from_boot", false)) {
            GameData.GetInstance().Remove("from_boot");
        } else {
            var track1 = LoadCache.GetInstance().LoadResource<AudioStreamOGGVorbis>("track1");
            GlobalMusicPlayer.Instance.FadeIn();
            GlobalMusicPlayer.Instance.Play(track1);
        }

        var canContinue = GameData.GetInstance().LoadNumber("last_level", -1) != -1;
        GetNode<Button>("MarginContainer/Buttons/Continue").Visible = canContinue;
    }

    public void StartGame() {
        GlobalMusicPlayer.Instance.FadeOut();
        SceneTransitioner.GetInstance().FadeToScene("res://screens/Game.tscn");
    }

    public void StartNewGame() {
        GlobalMusicPlayer.Instance.FadeOut();
        GameData.GetInstance().StoreNumber("last_level", 0);
        GameData.GetInstance().StoreNumber("deaths", 0);
        GameData.GetInstance().PersistToDisk();
        SceneTransitioner.GetInstance().FadeToScene("res://screens/Game.tscn");
    }
}
