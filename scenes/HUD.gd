extends CanvasLayer

const SETTINGS_HUD = preload("SettingsHUD.tscn")

func update_score(score):
	$ScoreLabel.text = str(score)

func game_over():
	$GameOver.popup()

func pause_popup():
	if !($GameOver.visible):
		GlobalVariables.pause = true
		$PausePopup.popup()

func _on_PauseButton_pressed():
	pause_popup()

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
