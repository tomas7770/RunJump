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
	_update_character()
	if GlobalVariables.is_save_locked():
		$HUD_Container/SaveWarning.visible = true

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

func _set_char_locked(locked):
	$HUD_Container/Label2.visible = !locked
	$HUD_Container/LockIcon.visible = locked
	$HUD_Container/LockLabel.visible = locked
	if locked:
		var reqs = GlobalVariables.UNLOCK_CHAR_REQ[GlobalVariables.selected_character]
		$HUD_Container/LockLabel.text = \
		"Score {x} with {y} on {z} to unlock".format({
			"x": reqs[0],
			"y": GlobalVariables.CHARACTER_STRINGS[reqs[1]],
			"z": GlobalVariables.DIFFICULTY_STRINGS[reqs[2]]})

func _update_character():
	var character = GlobalVariables.selected_character
	$HUD_Container/CharacterButton.text = CHARACTER_STRINGS[character]
	_set_char_locked(GlobalVariables.is_char_locked(character))
	var title = get_parent()
	title.update_character()

func _on_SettingsButton_pressed():
	loaded_settings_hud = SETTINGS_HUD.instance()
	get_parent().add_child(loaded_settings_hud)

func _on_DifficultyButton_pressed():
	GlobalVariables.next_difficulty()
	_update_hscore()
	_update_difficulty_label()

func _on_CharacterButton_pressed():
	GlobalVariables.next_character()
	_update_hscore()
	_update_character()

func _on_QuitButton_pressed():
	$HUD_Container/QuitDialog.popup()

func _on_AbortQuitButton_pressed():
	$HUD_Container/QuitDialog.visible = false

func _on_ConfirmQuitButton_pressed():
	get_tree().quit()
