using Godot;

public class ExitDoor : Area2D
{
    [Export]
    public bool InitialOpened = false;

    public bool IsExit = true;

    public bool Opened {
        get => _Opened;
        set => SetOpened(value);
    }

    private AnimationPlayer AnimationPlayer;

    private bool _Opened;

    public override void _Ready()
    {
        AnimationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
    }

    public void Activate()
    {
        Opened = InitialOpened;
    }

    private void SetOpened(bool value) {
        if (_Opened == value) {
            return;
        }

        _Opened = value;
        if (_Opened) {
            AnimationPlayer.Play("opened");
        } else {
            AnimationPlayer.Play("closed");
        }
    }
}
