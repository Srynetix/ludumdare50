using Godot;

public class Destructible : KinematicBody2D
{
    public int MaxHits = 3;

    private int CurrentHit = 0;
    private Sprite Sprite;
    private ShaderMaterial ShaderMaterial;
    private CPUParticles2D ExplosionFX;
    private CollisionShape2D CollisionShape2D;
    private AudioStreamPlayer AudioStreamPlayer;

    public override void _Ready()
    {
        ExplosionFX = GetNode<CPUParticles2D>("ExplosionFX");
        CollisionShape2D = GetNode<CollisionShape2D>("CollisionShape2D");
        AudioStreamPlayer = GetNode<AudioStreamPlayer>("AudioStreamPlayer");

        Sprite = GetNode<Sprite>("Sprite");
        ShaderMaterial = (ShaderMaterial)Sprite.Material;
    }

    public void Hit() {
        CurrentHit++;

        // Play sound at a random pitch
        AudioStreamPlayer.PitchScale = (float)GD.RandRange(0.5, 1.5);
        AudioStreamPlayer.Play();

        float amount = CurrentHit / (float)MaxHits;
        ShaderMaterial.SetShaderParam("dissolution_level", amount);

        if (CurrentHit >= MaxHits) {
            Explode();
        }
    }

    async public void Explode() {
        CollisionShape2D.Disabled = true;
        ExplosionFX.Emitting = true;
        await ToSignal(GetTree().CreateTimer(ExplosionFX.Lifetime), "timeout");

        QueueFree();
    }
}
