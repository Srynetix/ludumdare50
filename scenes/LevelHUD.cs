using Godot;
using SxGD;

public class LevelHUD : CanvasLayer
{
    [Signal]
    public delegate void level_ready();

    private bool WaitForHelpText = false;

    public void SetLevelData(int number, string name, string helpText, bool waitForHelpText = false) {
        GetNode<Label>("MarginContainer/LevelInfo/LevelNumber").Text = $"Level {number:00}";
        GetNode<Label>("MarginContainer/LevelInfo/LevelName").Text = name;
        GetNode<HelpText>("HelpText").Text = helpText;

        WaitForHelpText = waitForHelpText;
    }

    public void PlayAnimation(string anim) {
        GetNode<AnimationPlayer>("AnimationPlayer").Play(anim);
    }

    public void ShowText() {
        GetNode<HelpText>("HelpText").FadeIn();
    }

    async public void SendReadySignal() {
        ShowText();

        if (WaitForHelpText) {
            await ToSignal(GetNode<HelpText>("HelpText"), nameof(HelpText.shown));
        }

        EmitSignal(nameof(level_ready));
    }
}
