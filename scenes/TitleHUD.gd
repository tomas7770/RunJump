extends CanvasLayer

const SETTINGS_HUD = preload("SettingsHUD.tscn")

func _ready():
	update_hscore(GlobalVariables.highscore_get())
	$VersionLabel.text = GlobalVariables.GAME_VERSION

func update_hscore(score):
	$HighScore.text = str("High Score: ",score)

func _on_SettingsButton_pressed():
	add_child(SETTINGS_HUD.instance())
