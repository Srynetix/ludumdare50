using Godot;

public class SparklesFX : CPUParticles2D
{
    async public override void _Ready()
    {
        OneShot = true;

        await ToSignal(GetTree().CreateTimer(1.0f), "timeout");
        QueueFree();
    }
}
