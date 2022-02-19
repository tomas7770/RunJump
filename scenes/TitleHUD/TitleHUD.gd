extends CanvasLayer

const SETTINGS_HUD = preload("res://scenes/SettingsHUD/SettingsHUD.tscn")
const DIFFICULTY = GlobalVariables.DIFFICULTY
const DIFFICULTY_STRINGS = GlobalVariables.DIFFICULTY_STRINGS
const CHARACTER_STRINGS = GlobalVariables.CHARACTER_STRINGS
var loaded_settings_hud

func _ready():
	GlobalVariables.resize_control_toSafeArea($HUD_Container)
	_update_hscore()
	_update_difficulty_label()
	_update_character_label()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST \
	or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if loaded_settings_hud and is_instance_valid(loaded_settings_hud):
			return
		_on_QuitButton_pressed()

func _update_hscore():
	$HUD_Container/HighScore.text = str("High Score: ", GlobalVariables.highscore_get())

func _update_difficulty_label():
	$HUD_Container/DifficultyButton.text = DIFFICULTY_STRINGS[GlobalVariables.selected_difficulty]

func _update_character_label():
	$HUD_Container/CharacterButton.text = CHARACTER_STRINGS[GlobalVariables.selected_character]

func _on_SettingsButton_pressed():
	loaded_settings_hud = SETTINGS_HUD.instance()
	get_parent().add_child(loaded_settings_hud)

func _on_DifficultyButton_pressed():
	GlobalVariables.selected_difficulty = (GlobalVariables.selected_difficulty+1)%(DIFFICULTY.size())
	_update_hscore()
	_update_difficulty_label()

func _on_CharacterButton_pressed():
	GlobalVariables.next_character()
	_update_hscore()
	_update_character_label()

func _on_QuitButton_pressed():
	$HUD_Container/QuitDialog.popup()

func _on_AbortQuitButton_pressed():
	$HUD_Container/QuitDialog.visible = false

func _on_ConfirmQuitButton_pressed():
	get_tree().quit()
