extends CanvasLayer

const SETTINGS_HUD = preload("SettingsHUD.tscn")
const DIFFICULTY_STRINGS = GlobalVariables.DIFFICULTY_STRINGS

func update_score(score):
	$ScoreLabel.text = str(score)

func game_over():
	$GameOver.popup()

func update_difficulty_label(current_difficulty):
	$PausePopup.get_node("DifficultyLabel").text = "Difficulty: "+DIFFICULTY_STRINGS[current_difficulty]

func _pause_popup():
	if !($GameOver.visible):
		GlobalVariables.pause = true
		$PausePopup.popup()

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
	$PausePopup.visible = false

func _on_SettingsButton_pressed():
	add_child(SETTINGS_HUD.instance())
