extends CanvasLayer

const SETTINGS_HUD = preload("res://scenes/SettingsHUD/SettingsHUD.tscn")
const DIFFICULTY_STRINGS = GlobalVariables.DIFFICULTY_STRINGS

func _ready():
	GlobalVariables.resize_control_toSafeArea($HUD_Container)

func update_score(score):
	$HUD_Container/ScoreLabel.text = str(score)

func game_over():
	$HUD_Container/GameOver.popup()

func update_difficulty_label(current_difficulty):
	$HUD_Container/PausePopup/DifficultyLabel.text = "Difficulty: "+DIFFICULTY_STRINGS[current_difficulty]

func update_highscore_label(highscore):
	var target_string = "High Score: "+str(highscore)
	$HUD_Container/PausePopup/HighScoreLabel.text = target_string
	$HUD_Container/GameOver/HighScoreLabel.text = target_string

func newhighscore(old, new):
	$HUD_Container/GameOver/HighScoreLabel.text = "New High Score!\n("+str(old)+" -> "+str(new)+")"

func _pause_popup():
	if !($HUD_Container/GameOver.visible):
		GlobalVariables.pause = true
		$HUD_Container/PausePopup.popup()
		$HUD_Container/PausePopup.on_open()

func _on_PauseButton_pressed():
	_pause_popup()

func _on_TitleButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Title/Title.tscn")
	GlobalVariables.pause = false

func _on_RetryButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Main/Main.tscn")
	GlobalVariables.pause = false

func _on_ContinueButton_pressed():
	GlobalVariables.pause = false
	$HUD_Container/PausePopup.visible = false
	$HUD_Container/PausePopup.on_close()

func _on_SettingsButton_pressed():
	add_child(SETTINGS_HUD.instance())
