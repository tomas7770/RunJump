extends CanvasLayer

const SETTINGS_HUD = preload("SettingsHUD.tscn")
const DIFFICULTY = GlobalVariables.DIFFICULTY
const DIFFICULTY_STRINGS = GlobalVariables.DIFFICULTY_STRINGS

func _ready():
	GlobalVariables.resize_control_toSafeArea($HUD_Container)
	_update_hscore()
	_update_difficulty_label()

func _update_hscore():
	$HUD_Container/HighScore.text = str("High Score: ", GlobalVariables.highscore_get())

func _update_difficulty_label():
	$HUD_Container/DifficultyButton.text = DIFFICULTY_STRINGS[GlobalVariables.selected_difficulty]

func _on_SettingsButton_pressed():
	get_parent().add_child(SETTINGS_HUD.instance())

func _on_DifficultyButton_pressed():
	GlobalVariables.selected_difficulty = (GlobalVariables.selected_difficulty+1)%(DIFFICULTY.size())
	_update_hscore()
	_update_difficulty_label()

func _on_QuitButton_pressed():
	$HUD_Container/QuitDialog.popup()

func _on_AbortQuitButton_pressed():
	$HUD_Container/QuitDialog.visible = false

func _on_ConfirmQuitButton_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
