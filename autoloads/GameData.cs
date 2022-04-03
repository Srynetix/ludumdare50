using Godot;
using Godot.Collections;

public class GameData : Node
{
    private Dictionary _Data = new Dictionary();
    private static GameData _GlobalInstance;

    public static GameData Instance
    {
        get => _GlobalInstance;
    }

    public GameData()
    {
        if (_GlobalInstance == null)
        {
            _GlobalInstance = this;
            LoadFromDisk();
        }
    }

    public static GameData GetInstance() {
        return _GlobalInstance;
    }

    public void Store<T>(string name, T value)
    {
        _Data[name] = value;
    }

    public void StoreNumber(string name, float number) {
        Store(name, number);
    }

    public float LoadNumber(string name, float orDefault = 0) {
        return Load<float>(name, orDefault);
    }

    public void Increment(string name) {
        var number = LoadNumber(name, 0);
        StoreNumber(name, number + 1);
    }

    public void Remove(string name)
    {
        _Data.Remove(name);
    }

    public T Load<T>(string name, object orDefault = null)
    {
        if (_Data.Contains(name))
        {
            try {
                return (T)_Data[name];
            } catch (System.InvalidCastException e) {
                GD.PrintErr($"Trying to cast data at key '{name}' of type '{_Data[name].GetType()}' as a '{typeof(T)}'.");
                throw e;
            }
        }

        return (T)orDefault;
    }

    public void PersistToDisk() {
        File file = new File();
        file.Open("user://save.dat", File.ModeFlags.Write);
        file.StoreLine(JSON.Print(_Data));
        file.Close();
    }

    public void LoadFromDisk() {
        File file = new File();
        var error = file.Open("user://save.dat", File.ModeFlags.Read);
        if (error == Error.Ok) {
            _Data = (Dictionary)JSON.Parse(file.GetAsText()).Result;
            GD.Print("[DEBUG] Save loaded.");
            file.Close();
        }
        else if (error == Error.FileNotFound) {
            GD.Print("[DEBUG] Missing save data, will create.");
            PersistToDisk();
        }
    }
}
