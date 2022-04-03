using Godot;
using SxGD;

public class Game : Control
{
    [Export]
    public int CurrentLevelIdx = 1;
    [Export]
    public bool LoadFromSave = true;

    private Level _CurrentLevel = null;

    public override void _Ready()
    {
        var levelId = CurrentLevelIdx;
        if (LoadFromSave) {
            levelId = (int)GameData.GetInstance().LoadNumber("last_level", CurrentLevelIdx);
        }

        LoadLevel(levelId);
    }

    private string ChooseMusic(int levelId) {
        switch (levelId) {
            case 0:
            case 1:
            case 2:
                return "track2";
            case 3:
            case 4:
            case 5:
                return "track3";
            case 6:
            case 7:
                return "track4";
            default:
                return "track5";
        }

    }

    public async void LoadLevel(int levelId)
    {
        var levelPath = $"Level{levelId:00}";
        var transitioner = SceneTransitioner.GetInstance();

        if (_CurrentLevel != null)
        {
            transitioner.FadeOut();
            await ToSignal(transitioner, nameof(SceneTransitioner.animation_finished));
            _CurrentLevel.QueueFree();
        }

        var track = LoadCache.GetInstance().LoadResource<AudioStreamOGGVorbis>(ChooseMusic(levelId));
        GlobalMusicPlayer.Instance.FadeIn(0.5f);
        GlobalMusicPlayer.Instance.Play(track);

        if (!LoadCache.GetInstance().HasScene(levelPath)) {
            GameData.GetInstance().StoreNumber("last_level", levelId);
            GameData.GetInstance().PersistToDisk();
            _CurrentLevel = LoadCache.GetInstance().InstantiateScene<Level>("LevelEnd");
        } else {
            _CurrentLevel = LoadCache.GetInstance().InstantiateScene<Level>(levelPath);
        }

        _CurrentLevel.Connect(nameof(Level.success), this, nameof(LoadNextLevel));
        _CurrentLevel.Connect(nameof(Level.restart), this, nameof(ReloadCurrentLevel));
        AddChild(_CurrentLevel);

        transitioner.FadeIn();
        await ToSignal(transitioner, nameof(SceneTransitioner.animation_finished));

        CurrentLevelIdx = levelId;
    }

    public void LoadNextLevel()
    {
        LoadLevel(CurrentLevelIdx + 1);
    }

    public void ReloadCurrentLevel()
    {
        LoadLevel(CurrentLevelIdx);
    }
}
