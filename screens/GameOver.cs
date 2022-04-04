using System;
using Godot;
using SxGD;

public class GameOver : Control
{
    [Export]
    public bool GoodEnding = false;

    private readonly string BadHelpText = @"Hello [color=#abc123]again[/color].
You died [color=#abc123]{0}[/color] times, but thanks for beating the game.
Don't forget to rate it, and let me know if you liked it.

Until next time!";

    private readonly string GoodHelpText = @"ALERT ALERT, the [color=#abc123]test subject[/color] escaped!

Good for him, I have thousands like him waiting for a challenge.";

    public override void _Ready() {
        var deaths = GameData.GetInstance().LoadNumber("deaths", 0);
        var helpText = GetNode<HelpText>("HelpText");
        helpText.Text = GoodEnding ? GoodHelpText : string.Format(BadHelpText, deaths);
        helpText.FadeIn();
    }

    public void LoadTitle() {
        SceneTransitioner.GetInstance().FadeToScene("res://screens/Boot.tscn");
    }
}
