using Godot;
using SxGD;

public class Player : KinematicBody2D
{
    public Node BulletTarget;
    public bool DetectInput = true;

    private Vector2 Gravity = new Vector2(0, 25);
    private float MaxVelocity = 300;
    private float JumpSpeed = 550;
    private float MovementSpeed = 25;
    private float FrictionValue = 0.85f;
    private int MaxJumps = 2;

    [Signal]
    public delegate void exit();
    [Signal]
    public delegate void dead();

    private Vector2 Acceleration;
    private Vector2 Velocity;
    private Node2D Gun;
    private Sprite GunSprite;
    private Position2D Muzzle;
    private Sprite Sprite;
    private int CurrentJumps = 0;
    private bool IsOnIce = false;

    private Area2D AreaDetector;
    private CollisionShape2D AreaDetectorCollisionShape2D;
    private AudioStreamPlayer JumpFX;
    private AnimationPlayer AnimationPlayer;
    private CPUParticles2D JumpParticles;
    private CollisionShape2D CollisionShape2D;
    private bool _Dead = false;

    public override void _Ready()
    {
        Gun = GetNode<Node2D>("Gun");
        Muzzle = Gun.GetNode<Position2D>("Muzzle");
        GunSprite = Gun.GetNode<Sprite>("Sprite");
        Sprite = GetNode<Sprite>("Sprite");
        AreaDetector = GetNode<Area2D>("AreaDetector");
        AreaDetectorCollisionShape2D = AreaDetector.GetNode<CollisionShape2D>("CollisionShape2D");
        JumpFX = GetNode<AudioStreamPlayer>("JumpFX");
        AnimationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
        JumpParticles = GetNode<CPUParticles2D>("JumpParticles");
        CollisionShape2D = GetNode<CollisionShape2D>("CollisionShape2D");

        AreaDetector.Connect("area_entered", this, nameof(OnAreaDetectorEntered));
        AreaDetector.Connect("body_entered", this, nameof(OnAreaDetectorBodyEntered));
    }

    public override void _Process(float delta)
    {
        if (DetectInput) {
            // Move gun with mouse
            var localMousePosition = GetLocalMousePosition();
            Gun.Rotation = localMousePosition.Angle();

            // Flip sprite depending on rotation
            if (Gun.RotationDegrees > -90 && Gun.RotationDegrees < 90) {
                Sprite.FlipH = false;
                Gun.Scale = new Vector2(1, 1);
            } else {
                Sprite.FlipH = true;
                Gun.Scale = new Vector2(1, -1);
            }

            // Fire !
            if (Input.IsActionJustPressed("fire")) {
                var bullet = LoadCache.GetInstance().InstantiateScene<Bullet>();
                var trajectory = Vector2.Right.Rotated(Gun.Rotation);
                var bulletInitialVelocity = trajectory * 200;
                bullet.Position = Muzzle.GlobalPosition;
                bullet.InitialVelocity = bulletInitialVelocity;

                if (BulletTarget != null) {
                    BulletTarget.AddChild(bullet);
                } else {
                    GetParent().AddChild(bullet);
                }
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

        Velocity = MoveAndSlide(Velocity, Vector2.Up, true);

        IsOnIce = false;
        for (var i = 0; i < GetSlideCount(); ++i) {
            var collision = GetSlideCollision(i);
            if (collision.Collider is TileMap tileMap) {
                var coord = tileMap.WorldToMap(collision.Position - collision.Normal) / tileMap.Scale;
                var tileId = tileMap.GetCellv(coord);
                if (tileId != -1) {
                    var name = tileMap.TileSet.TileGetName(tileId);
                    if (name == "ice") {
                        IsOnIce = true;
                    }
                }
            }
        }

        if (IsOnFloor()) {
            CurrentJumps = 0;
        }
    }

    private void ApplyInput() {
        var side_direction = 0;

        if (DetectInput) {
            if (Input.IsActionPressed("move_left")) {
                side_direction -= 1;
            }

            if (Input.IsActionPressed("move_right")) {
                side_direction += 1;
            }

            if (Input.IsActionJustPressed("jump")) {
                // Jump mid-air
                if (!IsOnFloor()) {
                    if (CurrentJumps == 0) {
                        // Force one jump
                        CurrentJumps += 1;
                    }
                }

                if (CurrentJumps < MaxJumps) {
                    Acceleration += Vector2.Up * JumpSpeed + (Vector2.Up * Velocity.y);
                    CurrentJumps += 1;

                    JumpFX.PitchScale = (float)GD.RandRange(0.95, 1.05);
                    JumpFX.Play();

                    JumpParticles.Restart();
                    JumpParticles.Emitting = true;
                }
            }

            else if (Input.IsActionJustReleased("jump")) {
                // Stop jump mid-air
                if (Velocity.y < 0) {
                    Acceleration += Vector2.Up * Velocity.y / 2;
                }
            }
        }

        if (side_direction == 0) {
            if (!IsOnIce) {
                ApplySideFriction();
            }
            AnimationPlayer.Play("idle");
        } else {
            Acceleration += Vector2.Right * side_direction * MovementSpeed;
            AnimationPlayer.Play("run");
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

    public void Kill() {
        if (!_Dead) {
            _Dead = true;
            SetPhysicsProcess(false);
            EmitSignal(nameof(dead));
        }
    }

    public void Exit() {
        CollisionShape2D.SetDeferred("disabled", true);
        AreaDetectorCollisionShape2D.SetDeferred("disabled", true);
        AnimationPlayer.Play("fade");
        SetPhysicsProcess(false);
        EmitSignal(nameof(exit));
    }

    private void OnAreaDetectorEntered(Area2D area) {
        if (area is ExitDoor door) {
            if (door.IsExit && door.Opened) {
                Exit();
            }
        }

        else if (area is Spikes) {
            Kill();
        }

        else if (area is PushButton button) {
            button.Press();
        }
    }

    private void OnAreaDetectorBodyEntered(Node body) {
        if (body is Bullet bullet) {
            if (bullet.HurtPlayer) {
                bullet.Destroy();
                Kill();
            }
        }
    }
}
