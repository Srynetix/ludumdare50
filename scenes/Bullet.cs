using Godot;
using SxGD;

public class Bullet : KinematicBody2D
{
    public bool HurtPlayer = false;
    public Vector2 InitialVelocity = Vector2.Right * 100;
    public int MaxBounces = 2;

    private float MaxVelocity = 800;
    private Vector2 Acceleration;
    private Vector2 Velocity;
    private float Bounces = 0;

    private bool Frozen = false;

    private static GlobalAudioFxPlayer GlobalAudioFxPlayer;

    public override void _Ready()
    {
        if (GlobalAudioFxPlayer == null) {
            GlobalAudioFxPlayer = GetNode<GlobalAudioFxPlayer>("/root/GameGlobalAudioFxPlayer");
        }

        if (HurtPlayer) {
            Modulate = Colors.Red;
            SetCollisionMaskBit(2, true); // Player
        }

        Rotation = InitialVelocity.Angle();

        GlobalAudioFxPlayer.Play("shoot");
    }

    public void Destroy() {
        ShowSparkles();
        QueueFree();
    }

    public void ShowSparkles() {
        var sparkles = LoadCache.GetInstance().InstantiateScene<SparklesFX>();
        GetParent().AddChild(sparkles);
        sparkles.GlobalPosition = GlobalPosition;

        GlobalAudioFxPlayer.Play("click");
    }

    public void Freeze() {
        Frozen = true;
    }

    public void Unfreeze() {
        Frozen = false;
    }

    public override void _PhysicsProcess(float delta) {
        if (Frozen) {
            return;
        }

        Acceleration = Vector2.Zero;
        Acceleration += InitialVelocity;

        Velocity += Acceleration;
        ClampVelocity();

        var collision = MoveAndCollide(Velocity * delta);
        if (collision != null) {
            ShowSparkles();

            if (collision.Collider is TimeBomb bomb) {
                bomb.Freeze();
                QueueFree();
            }

            else if (collision.Collider is Destructible destructible) {
                destructible.Hit();
                QueueFree();
            }

            InitialVelocity = InitialVelocity.Bounce(collision.Normal);
            Rotation = InitialVelocity.Angle();
            Velocity = Velocity.Bounce(collision.Normal);
            Bounces++;

            collision.Dispose();
        }

        RemoveIfTooManyBounces();
    }

    private void ClampVelocity() {
        Velocity = Velocity.Clamped(MaxVelocity);
    }

    private void RemoveIfTooManyBounces() {
        if (Bounces > MaxBounces) {
            QueueFree();
        }
    }
}
