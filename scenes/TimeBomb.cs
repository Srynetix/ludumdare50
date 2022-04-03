using Godot;

public class TimeBomb : KinematicBody2D
{
	[Export]
	public float InitialTime = 30;
	[Export]
	public float FreezeTime = 2;

	[Signal]
	public delegate void timeout();

	private Timer Timer;
	private Timer FreezeTimer;
	private Label Label;
	private AnimationPlayer AnimationPlayer;

	private float RemainingTime;

	public override void _Ready()
	{
		Timer = GetNode<Timer>("Timer");
		FreezeTimer = GetNode<Timer>("FreezeTimer");
		Label = GetNode<Label>("Label");
		AnimationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");

		RemainingTime = InitialTime;
		UpdateLabel();

		Timer.WaitTime = InitialTime;
		Timer.Connect("timeout", this, nameof(OnTimerTimeout));

		FreezeTimer.WaitTime = FreezeTime;
		FreezeTimer.Connect("timeout", this, nameof(OnFreezeTimerTimeout));
	}

    public void Activate() {
		Timer.Start();
		AnimationPlayer.Play("running");
    }

	public override void _Process(float delta) {
        if (!Timer.IsStopped()) {
            RemainingTime = Timer.TimeLeft;
            UpdateLabel();
        }
	}

	private void OnTimerTimeout() {
		EmitSignal(nameof(timeout));
	}

	private void OnFreezeTimerTimeout() {
		Timer.Paused = false;

        foreach (Turret turret in GetTree().GetNodesInGroup("turret")) {
            turret.Unfreeze();
        }

        foreach (Bullet bullet in GetTree().GetNodesInGroup("bullet")) {
            if (bullet.HurtPlayer) {
                bullet.Unfreeze();
            }
        }

		AnimationPlayer.Play("running");
	}

	private void UpdateLabel() {
		Label.Text = $"{RemainingTime:0.00}".Replace(",", "'");
	}

	public void Freeze() {
		Timer.Paused = true;
		FreezeTimer.Start();
		AnimationPlayer.Play("freezed");

        foreach (Turret turret in GetTree().GetNodesInGroup("turret")) {
            turret.Freeze();
        }

        foreach (Bullet bullet in GetTree().GetNodesInGroup("bullet")) {
            if (bullet.HurtPlayer) {
                bullet.Freeze();
            }
        }
	}

	public void Stop() {
		Timer.Paused = true;
		FreezeTimer.Stop();
		AnimationPlayer.Play("freezed");
	}
}
