extends CanvasLayer

const SETTINGS_HUD = preload("SettingsHUD.tscn")
const DIFFICULTY_STRINGS = GlobalVariables.DIFFICULTY_STRINGS
enum PAUSEINFO {DIFFICULTY, HIGHSCORE}
var current_pause_info = PAUSEINFO.DIFFICULTY

func update_score(score):
	$HUD_Container/ScoreLabel.text = str(score)

func game_over():
	$HUD_Container/GameOver.popup()

func update_difficulty_label(current_difficulty):
	$HUD_Container/PausePopup/DifficultyLabel.text = "Difficulty: "+DIFFICULTY_STRINGS[current_difficulty]

func update_highscore_label(highscore):
	$HUD_Container/PausePopup/HighScoreLabel.text = "High Score: "+str(highscore)

func _pause_popup():
	if !($HUD_Container/GameOver.visible):
		GlobalVariables.pause = true
		$HUD_Container/PausePopup.popup()
		$HUD_Container/PausePopup/InfoFadeTimer.start()

func _on_PauseButton_pressed():
	_pause_popup()

func _on_TitleButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Title.tscn")
	GlobalVariables.pause = false

func _on_RetryButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Main.tscn")
	GlobalVariables.pause = false

func _on_ContinueButton_pressed():
	GlobalVariables.pause = false
	$HUD_Container/PausePopup.visible = false
	$HUD_Container/PausePopup/InfoFadeTimer.stop()

func _on_SettingsButton_pressed():
	add_child(SETTINGS_HUD.instance())

func _on_InfoFadeTimer_timeout():
	match current_pause_info:
		PAUSEINFO.DIFFICULTY:
			$HUD_Container/PausePopup/AnimationPlayer.play("PauseInfoFade")
			current_pause_info = PAUSEINFO.HIGHSCORE
		PAUSEINFO.HIGHSCORE:
			$HUD_Container/PausePopup/AnimationPlayer.play_backwards("PauseInfoFade")
			current_pause_info = PAUSEINFO.DIFFICULTY
