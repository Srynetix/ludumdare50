using Godot;

public class PushButton : Area2D
{
    [Signal]
    public delegate void pressed();

    public bool Pressed {
        get => _Pressed;
    }

    private bool _Pressed = false;

    public void Press() {
        if (!_Pressed) {
            _Pressed = true;
            GetNode<AnimationPlayer>("AnimationPlayer").Play("pressed");
            EmitSignal(nameof(pressed));
        }
    }
}
