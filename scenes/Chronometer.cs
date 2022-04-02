using Godot;

public class Chronometer : KinematicBody2D
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
	private float RemainingTime;

	public override void _Ready()
	{
		Timer = GetNode<Timer>("Timer");
		FreezeTimer = GetNode<Timer>("FreezeTimer");
		Label = GetNode<Label>("Label");

		RemainingTime = InitialTime;
		UpdateLabel();

		Timer.WaitTime = InitialTime;
		Timer.Connect("timeout", this, nameof(OnTimerTimeout));
		Timer.Start();

		FreezeTimer.WaitTime = FreezeTime;
		FreezeTimer.Connect("timeout", this, nameof(OnFreezeTimerTimeout));
	}

	public override void _Process(float delta) {
		RemainingTime = Timer.TimeLeft;
		UpdateLabel();
	}

	private void OnTimerTimeout() {
		EmitSignal(nameof(timeout));
	}

	private void OnFreezeTimerTimeout() {
		Timer.Paused = false;
		Label.Modulate = Colors.White;
	}

	private void UpdateLabel() {
		Label.Text = $"{RemainingTime:0.00}".Replace(",", "'");
	}

	public void Freeze() {
		Timer.Paused = true;
		FreezeTimer.Start();
		Label.Modulate = Colors.BlueViolet;
	}
}
