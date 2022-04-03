using Godot;
using Godot.Collections;
using SxGD;

public class Turret : Area2D
{
    public int MaxHits = 3;
    public Node BulletTarget;
    public bool Firing;
    public float FireRate = 1;

    private Node2D Gun;
    private Position2D Muzzle;
    private Timer Timer;
    private AnimationPlayer AnimationPlayer;
    private CollisionShape2D CollisionShape2D;
    private AudioStreamPlayer AudioStreamPlayer;

    private Array<Player> Players = new Array<Player>();
    private Player NearestPlayer = null;
    private bool Stopped = false;
    private int CurrentHit = 0;
    private bool Exploded = false;
    private bool Frozen = false;

    public override void _Ready()
    {
        Gun = GetNode<Node2D>("Gun");
        Muzzle = Gun.GetNode<Position2D>("Muzzle");
        Timer = GetNode<Timer>("Timer");
        AnimationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
        AudioStreamPlayer = GetNode<AudioStreamPlayer>("AudioStreamPlayer");
        CollisionShape2D = GetNode<CollisionShape2D>("CollisionShape2D");

        Connect("body_entered", this, nameof(OnBodyEntered));

        Timer.WaitTime = FireRate;
        Timer.Connect("timeout", this, nameof(OnTimerTimeout));
    }

    public override void _Process(float delta)
    {
        if (!Stopped && !Exploded) {
            DetectNearestPlayer();
            AimNearestPlayer();
        }
    }

    public void Activate() {
        foreach (Player node in GetTree().GetNodesInGroup("player")) {
            Players.Add(node);
        }

        Timer.Start();
    }

    public void Start() {
        Stopped = false;
        Timer.Start();
    }

    public void Stop() {
        Stopped = true;
        NearestPlayer = null;
        Timer.Stop();
    }

    public void Freeze() {
        Stop();
    }

    public void Unfreeze() {
        Start();
    }

    private void OnTimerTimeout() {
        if (NearestPlayer != null && !Exploded) {
            Fire();
        }
    }

    private void DetectNearestPlayer() {
        Player nearestPlayer = null;
        float nearestDistance = Mathf.Inf;
        foreach (Player player in Players) {
            var dist = Position.DistanceSquaredTo(player.Position);
            if (dist < nearestDistance) {
                nearestDistance = dist;
                nearestPlayer = player;
            }
        }

        NearestPlayer = nearestPlayer;
    }

    private void AimNearestPlayer() {
        if (NearestPlayer != null) {
            var dir = Position.DirectionTo(NearestPlayer.Position);
            Gun.Rotation = dir.Angle();
        }
    }

    public void Fire() {
        var bullet = LoadCache.GetInstance().InstantiateScene<Bullet>();
        var trajectory = Vector2.Right.Rotated(Gun.Rotation);
        var bulletInitialVelocity = trajectory * 200;
        bullet.HurtPlayer = true;
        bullet.MaxBounces = 0;
        bullet.Position = Muzzle.GlobalPosition;
        bullet.InitialVelocity = bulletInitialVelocity;

        if (BulletTarget != null) {
            BulletTarget.AddChild(bullet);
        } else {
            GetParent().AddChild(bullet);
        }
    }

    public void Hit() {
        CurrentHit++;

        // Play sound at a random pitch
        AudioStreamPlayer.PitchScale = (float)GD.RandRange(0.5, 1.5);
        AudioStreamPlayer.Play();

        if (CurrentHit >= MaxHits) {
            Explode();
        }
    }

    public void Explode() {
        Exploded = true;
        CollisionShape2D.SetDeferred("disabled", true);
        AnimationPlayer.Play("explode");
    }

    private void OnBodyEntered(Node body) {
        if (body is Bullet bullet) {
            bullet.Destroy();
            Hit();
        }
    }
}
