extends CanvasLayer

const SETTINGS_HUD = preload("res://scenes/SettingsHUD/SettingsHUD.tscn")
const DIFFICULTY_STRINGS = GlobalVariables.DIFFICULTY_STRINGS
var loaded_settings_hud

func _ready():
	GlobalVariables.resize_control_toSafeArea($HUD_Container)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST \
	or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if loaded_settings_hud and is_instance_valid(loaded_settings_hud):
			return
		if $HUD_Container/PausePopup.visible:
			_on_ContinueButton_pressed()
		else:
			_on_PauseButton_pressed()

func update_score(score):
	$HUD_Container/ScoreLabel.text = str(score)

func game_over():
	$HUD_Container/GameOver.popup()

func update_difficulty_label(current_difficulty):
	var target_string = "Difficulty: "+DIFFICULTY_STRINGS[current_difficulty]
	$HUD_Container/PausePopup/DifficultyLabel.text = target_string
	$HUD_Container/GameOver/DifficultyLabel.text = target_string

func update_highscore_label(highscore):
	var target_string = "High Score: "+str(highscore)
	$HUD_Container/PausePopup/HighScoreLabel.text = target_string
	$HUD_Container/GameOver/HighScoreLabel.text = target_string

func newhighscore(old, new):
	$HUD_Container/GameOver.on_new_highscore(old, new)

func _pause_popup():
	if !($HUD_Container/GameOver.visible or $HUD_Container/PausePopup.visible):
		GlobalVariables.pause = true
		$HUD_Container/PausePopup.popup()
		$HUD_Container/PausePopup.on_open()

func _on_PauseButton_pressed():
	_pause_popup()

func _on_TitleButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Title/Title.tscn")
	GlobalVariables.pause = false

func _on_pauseTitleButton_pressed():
	$HUD_Container/ConfirmTitleDialog.popup()

func _on_RetryButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Main/Main.tscn")
	GlobalVariables.pause = false

func _on_ContinueButton_pressed():
	GlobalVariables.pause = false
	$HUD_Container/PausePopup.visible = false
	$HUD_Container/PausePopup.on_close()

func _on_SettingsButton_pressed():
	loaded_settings_hud = SETTINGS_HUD.instance()
	add_child(loaded_settings_hud)

func _on_AbortTitleButton_pressed():
	$HUD_Container/ConfirmTitleDialog.visible = false
