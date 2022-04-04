using System.Threading.Tasks;
using Godot;
using Godot.Collections;
using SxGD;

public class Level : Node2D
{
    [Export]
    public int LevelNumber = 1;
    [Export]
    public string LevelName = "Hello World";
    [Export]
    public int BombTime = 30;
    [Export(PropertyHint.MultilineText)]
    public string HelpText = "Hello.";
    [Export]
    public bool WaitForHelpText = false;
    [Export]
    public float TurretFireRate = 1;
    [Export]
    public bool LockCamera = false;

    [Signal]
    public delegate void success();
    [Signal]
    public delegate void restart();

    private Node AreasTarget;
    private Node FXTarget;
    private Node PlayersTarget;

    private Array<Player> Players = new Array<Player>();
    private Array<TimeBomb> TimeBombs = new Array<TimeBomb>();
    private Array<ExitDoor> ExitDoors = new Array<ExitDoor>();
    private Array<PushButton> PushButtons = new Array<PushButton>();
    private Array<Turret> Turrets = new Array<Turret>();

    private TileMap TileMap;
    private LevelHUD LevelHUD;
    private AudioStreamPlayer SuccessFX;
    private FXCamera Camera;
    private bool Finished = false;

    public override void _Ready()
    {
        TileMap = GetNode<TileMap>("Middleground");
        LevelHUD = GetNode<LevelHUD>("LevelHUD");
        SuccessFX = GetNode<AudioStreamPlayer>("SuccessFX");
        Camera = GetNode<FXCamera>("Camera");
        LevelHUD.Connect(nameof(LevelHUD.level_ready), this, nameof(Activate));
        LevelHUD.SetLevelData(LevelNumber, LevelName, HelpText, WaitForHelpText);

        AreasTarget = GetNode<Node>("Areas");
        FXTarget = GetNode<Node>("FX");
        PlayersTarget = GetNode<Node>("Players");

        CallDeferred(nameof(SpawnTiles));

        // Prepare camera
        var rect = TileMap.GetUsedRect();
        var size = rect.Position + rect.Size;
        var vpSize = GetViewportRect().Size;
        Camera.LimitLeft = 0;
        Camera.LimitTop = 0;
        Camera.SmoothingEnabled = true;

        if (LockCamera) {
            Camera.LimitRight = (int)vpSize.x;
            Camera.LimitBottom = (int)vpSize.y;
        } else {
            Camera.LimitRight = (int)Mathf.Max(size.x * TileMap.CellSize.x * TileMap.Scale.x, vpSize.x);
            Camera.LimitBottom = (int)Mathf.Max(size.y * TileMap.CellSize.y * TileMap.Scale.x, vpSize.y);
        }
    }

    private void SpawnTiles() {
        foreach (Vector2 pos in TileMap.GetUsedCells())
        {
            var tileIdx = TileMap.GetCellv(pos);
            var tileName = TileMap.TileSet.TileGetName(tileIdx);

            if (tileName == "destructible") {
                var tile = LoadCache.GetInstance().InstantiateScene<Destructible>();
                tile.Position = (TileMap.MapToWorld(pos) + TileMap.CellSize / 2) * TileMap.Scale.x;
                AreasTarget.AddChild(tile);
                TileMap.SetCellv(pos, -1);
            }

            else if (tileName == "exit") {
                var tile = LoadCache.GetInstance().InstantiateScene<ExitDoor>();
                tile.Position = (TileMap.MapToWorld(pos) + TileMap.CellSize / 2 + new Vector2(0, TileMap.CellSize.y / 2.0f)) * TileMap.Scale.x;
                AreasTarget.AddChild(tile);
                TileMap.SetCellv(pos, -1);
                ExitDoors.Add(tile);
            }

            else if (tileName == "start") {
                var tile = LoadCache.GetInstance().InstantiateScene<ExitDoor>();
                tile.IsExit = false;
                tile.Position = (TileMap.MapToWorld(pos) + TileMap.CellSize / 2 + new Vector2(0, TileMap.CellSize.y / 2.0f)) * TileMap.Scale.x;
                AreasTarget.AddChild(tile);
                TileMap.SetCellv(pos, -1);
                ExitDoors.Add(tile);

                var player = LoadCache.GetInstance().InstantiateScene<Player>();
                player.Position = tile.Position;
                player.BulletTarget = FXTarget;
                player.DetectInput = false;
                PlayersTarget.AddChild(player);
                player.Connect(nameof(Player.exit), this, nameof(OnPlayerExit), new Array { player });
                player.Connect(nameof(Player.dead), this, nameof(OnPlayerDead), new Array { player });
                Players.Add(player);
            }

            else if (tileName == "bomb") {
                var tile = LoadCache.GetInstance().InstantiateScene<TimeBomb>();
                tile.Position = (TileMap.MapToWorld(pos) + TileMap.CellSize / 2 + new Vector2(TileMap.CellSize.x / 2.0f, 0)) * TileMap.Scale.x;
                tile.InitialTime = BombTime;
                AreasTarget.AddChild(tile);
                TileMap.SetCellv(pos, -1);
                tile.Connect(nameof(TimeBomb.timeout), this, nameof(OnBombExplosion), new Array { tile });
                TimeBombs.Add(tile);
            }

            else if (tileName == "spikes") {
                var tile = LoadCache.GetInstance().InstantiateScene<Spikes>();
                tile.Rotation = GetCellRotation(pos);
                tile.Position = (TileMap.MapToWorld(pos) + TileMap.CellSize / 2) * TileMap.Scale.x;
                AreasTarget.AddChild(tile);
                TileMap.SetCellv(pos, -1);
            }

            else if (tileName == "button") {
                var tile = LoadCache.GetInstance().InstantiateScene<PushButton>();
                tile.Rotation = GetCellRotation(pos);
                tile.Position = (TileMap.MapToWorld(pos) + TileMap.CellSize / 2) * TileMap.Scale.x;
                AreasTarget.AddChild(tile);
                TileMap.SetCellv(pos, -1);
                PushButtons.Add(tile);
                tile.Connect(nameof(PushButton.pressed), this, nameof(TryToOpenDoors));
            }

            else if (tileName == "glass") {
                var tile = LoadCache.GetInstance().InstantiateScene<Glass>();
                tile.Rotation = GetCellRotation(pos);
                tile.Position = (TileMap.MapToWorld(pos) + TileMap.CellSize / 2) * TileMap.Scale.x;
                AreasTarget.AddChild(tile);
                TileMap.SetCellv(pos, -1);
            }

            else if (tileName == "turret") {
                var tile = LoadCache.GetInstance().InstantiateScene<Turret>();
                tile.FireRate = TurretFireRate;
                tile.Rotation = GetCellRotation(pos);
                tile.Position = (TileMap.MapToWorld(pos) + TileMap.CellSize / 2) * TileMap.Scale.x;
                AreasTarget.AddChild(tile);
                TileMap.SetCellv(pos, -1);
                Turrets.Add(tile);
            }
        }
    }

    public override void _Process(float delta)
    {
        if (!Finished) {
            if (Players.Count > 0) {
                var player = Players[0];
                Camera.GlobalPosition = player.GlobalPosition;
            }
        }
    }

    public override void _Input(InputEvent @event)
    {
        if (@event is InputEventKey key) {
            if (key.Scancode == (int)KeyList.Enter) {
                if (!GameData.GetInstance().HasValue("from_game")) {
                    GetTree().ReloadCurrentScene();
                }
            }
        }
    }

    public void Activate() {
        foreach (var player in Players) {
            player.DetectInput = true;
        }

        foreach (var bomb in TimeBombs) {
            bomb.Activate();
        }

        foreach (var door in ExitDoors) {
            door.Activate();
        }

        foreach (var turret in Turrets) {
            turret.Activate();
        }
    }

    private float GetCellRotation(Vector2 cellPosition) {
        var transposed = TileMap.IsCellTransposed((int)cellPosition.x, (int)cellPosition.y);
        var flipX = TileMap.IsCellXFlipped((int)cellPosition.x, (int)cellPosition.y);
        var flipY = TileMap.IsCellYFlipped((int)cellPosition.x, (int)cellPosition.y);

        if (!transposed && !flipX && !flipY) {
            return 0;
        }

        if (transposed && !flipX && flipY) {
            return -Mathf.Pi / 2;
        }

        if (!transposed && flipX) {
            return Mathf.Pi;
        }

        if (transposed && flipX && !flipY) {
            return Mathf.Pi / 2;
        }

        GD.Print("Unknown", transposed, flipX, flipY);
        return 0;
    }

    private void StopMechanisms() {
        Finished = true;

        foreach (var player1 in Players) {
            player1.DetectInput = false;
        }

        foreach (var timeBomb in TimeBombs) {
            timeBomb.Stop();
        }

        foreach (var turret in Turrets) {
            turret.Stop();
        }

        foreach (Bullet bullet in GetTree().GetNodesInGroup("bullet")) {
            bullet.QueueFree();
        }
    }

    async private void GameOver() {
        GameData.GetInstance().Increment("deaths");
        GameData.GetInstance().PersistToDisk();

        LevelHUD.PlayAnimation("game_over");
        await ToSignal(GetTree().CreateTimer(1), "timeout");

        if (LevelNumber == int.MaxValue) {
            SceneTransitioner.GetInstance().FadeToScene("res://screens/GameOver.tscn");
        } else {
            EmitSignal(nameof(restart));
        }
    }

    private void OnPlayerDead(Player player) {
		var explosion = LoadCache.GetInstance().InstantiateScene<ExplosionFX>();
		FXTarget.AddChild(explosion);

		explosion.Position = player.Position;
		explosion.Explode();

        StopMechanisms();
        GameOver();
    }

    async private void OnBombExplosion(TimeBomb bomb) {
        StopMechanisms();

        // Move cam on bomb
        await ZoomOnPosition(bomb.GlobalPosition);

		var explosion = LoadCache.GetInstance().InstantiateScene<ExplosionFX>();
		FXTarget.AddChild(explosion);
		explosion.Position = bomb.Position;
		explosion.Explode();

        GameOver();
    }

    async private Task ZoomOnPosition(Vector2 position) {
        Camera.LimitLeft = -1000000;
        Camera.LimitRight = 1000000;
        Camera.LimitTop = -1000000;
        Camera.LimitBottom = 1000000;
        Camera.SmoothingEnabled = false;
        await Camera.TweenToPosition(position, zoom: 0.5f);
    }

    async private void OnPlayerExit(Player player) {
        StopMechanisms();

        LevelHUD.PlayAnimation("win");
        SuccessFX.Play();

        await ToSignal(GetTree().CreateTimer(1), "timeout");

        if (LevelNumber == int.MaxValue) {
            SceneTransitioner.GetInstance().FadeToScene("res://screens/GameOverGood.tscn");
        } else {
            EmitSignal(nameof(success));
        }
    }

    private void TryToOpenDoors() {
        foreach (var btn in PushButtons) {
            if (!btn.Pressed) {
                return;
            }
        }

        foreach (var door in ExitDoors) {
            if (door.IsExit && !door.Opened) {
                door.Opened = true;
            }
        }
    }
}
