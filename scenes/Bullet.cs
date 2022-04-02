using Godot;

public class Bullet : KinematicBody2D
{
    public Vector2 InitialVelocity = Vector2.Right * 100;
    public int MaxBounces = 2;

    private float MaxVelocity = 800;
    private Vector2 Acceleration;
    private Vector2 Velocity;
    private float Bounces = 0;

    public override void _PhysicsProcess(float delta)
    {
        Acceleration = Vector2.Zero;
        Acceleration += InitialVelocity;

        Velocity += Acceleration;
        ClampVelocity();

        var collision = MoveAndCollide(Velocity * delta);
        if (collision != null) {
            if (collision.Collider is Chronometer chrono) {
                chrono.Freeze();
                QueueFree();
            }

            InitialVelocity = InitialVelocity.Bounce(collision.Normal);
            Velocity = Velocity.Bounce(collision.Normal);
            Bounces++;
        }

        RemoveIfTooManyBounces();
        RemoveIfOutOfBounds();
    }

    private void ClampVelocity() {
        Velocity = Velocity.Clamped(MaxVelocity);
    }

    private void RemoveIfOutOfBounds() {
        var screenRect = GetViewportRect();

        if (!screenRect.HasPoint(Position)) {
            QueueFree();
        }
    }

    private void RemoveIfTooManyBounces() {
        if (Bounces > MaxBounces) {
            QueueFree();
        }
    }
}
