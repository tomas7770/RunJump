extends CanvasLayer

const SETTINGS_HUD = preload("SettingsHUD.tscn")
const DIFFICULTY = GlobalVariables.DIFFICULTY
const DIFFICULTY_STRINGS = {DIFFICULTY.NORMAL:"Normal", DIFFICULTY.EASY:"Easy"}

func _ready():
	_update_hscore()
	_update_difficulty_label()
	$VersionLabel.text = GlobalVariables.GAME_VERSION

func _update_hscore():
	$HighScore.text = str("High Score: ", GlobalVariables.highscore_get())

func _update_difficulty_label():
	$DifficultyButton.text = DIFFICULTY_STRINGS[GlobalVariables.selected_difficulty]

func _on_SettingsButton_pressed():
	get_parent().add_child(SETTINGS_HUD.instance())

func _on_DifficultyButton_pressed():
	GlobalVariables.selected_difficulty = (GlobalVariables.selected_difficulty+1)%(DIFFICULTY.size())
	_update_hscore()
	_update_difficulty_label()
