using Godot;

public class ExplosionFX : Node2D
{
    public void Explode()
    {
        GetNode<AnimationPlayer>("AnimationPlayer").Play("explode");
    }
}
