using Godot;
using SxGD;

public class HelpText : CanvasLayer
{
    [Signal]
    public delegate void shown();

    [Export(PropertyHint.MultilineText)]
    public string Text = "";

    private FadingRichTextLabel _Label;

    public override void _Ready()
    {
        _Label = GetNode<FadingRichTextLabel>("MarginContainer/FadingRichTextLabel");
        _Label.Connect(nameof(FadingRichTextLabel.shown), this, nameof(_Label_Shown));
    }

    private void _Label_Shown() {
        EmitSignal(nameof(shown));
    }

    public void FadeIn() {
        _Label.UpdateText(Text);
        _Label.FadeIn();
    }
}
