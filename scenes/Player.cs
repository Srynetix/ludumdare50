using Godot;

public class Player : KinematicBody2D
{
    private Vector2 Gravity = new Vector2(0, 25);
    private float MaxVelocity = 400;
    private float JumpSpeed = 500;
    private float MovementSpeed = 50;
    private float FrictionValue = 0.25f;
    private int MaxJumps = 2;

    private Vector2 Acceleration;
    private Vector2 Velocity;
    private Node2D Gun;
    private int CurrentJumps = 0;

    private static PackedScene BulletScene;

    public override void _Ready()
    {
        Gun = GetNode<Node2D>("Gun");

        if (BulletScene == null) {
            BulletScene = GD.Load<PackedScene>("res://scenes/Bullet.tscn");
        }
    }

    public override void _Process(float delta)
    {
        // Move gun with mouse
        var localMousePosition = GetLocalMousePosition();
        Gun.Rotation = localMousePosition.Angle();

        // Fire !
        if (Input.IsActionJustPressed("fire")) {
            var bullet = BulletScene.Instance<Bullet>();
            var trajectory = Vector2.Right.Rotated(Gun.Rotation);
            var bulletPosition = trajectory * 20;
            var bulletInitialVelocity = trajectory * 200;
            bullet.Position = Gun.GetNode<Sprite>("Sprite").GlobalPosition + bulletPosition;
            bullet.InitialVelocity = bulletInitialVelocity;

            if (Owner != null) {
                Owner.AddChild(bullet);
            } else {
                GetTree().Root.AddChild(bullet);
            }
        }
    }

    public override void _PhysicsProcess(float delta)
    {
        Acceleration = Vector2.Zero;

        ApplyInput();
        ApplyGravity();

        Velocity += Acceleration;
        ClampVelocity();

        Velocity = MoveAndSlide(Velocity, Vector2.Up);

        if (IsOnFloor()) {
            CurrentJumps = 0;
        }
    }

    private void ApplyInput() {
        var side_direction = 0;

        if (Input.IsActionPressed("move_left")) {
            side_direction -= 1;
        }

        if (Input.IsActionPressed("move_right")) {
            side_direction += 1;
        }

        if (Input.IsActionJustPressed("jump")) {
            if (CurrentJumps == 0 && IsOnFloor() || CurrentJumps > 0 && CurrentJumps < MaxJumps) {
                Acceleration += Vector2.Up * JumpSpeed + (Vector2.Up * Velocity.y);
                CurrentJumps += 1;
            }
        }

        if (side_direction == 0) {
            ApplySideFriction();
        } else {
            Acceleration += Vector2.Right * side_direction * MovementSpeed;
        }
    }

    private void ApplyGravity() {
        Acceleration += Gravity;
    }

    private void ClampVelocity() {
        Velocity.x = Mathf.Clamp(Velocity.x, -MaxVelocity, MaxVelocity);
    }

    private void ApplySideFriction() {
        Acceleration += new Vector2(Mathf.Lerp(-Velocity.x, 0, 1 - FrictionValue), 0);
    }
}
