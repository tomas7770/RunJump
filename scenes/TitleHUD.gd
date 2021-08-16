extends CanvasLayer

const SETTINGS_HUD = preload("SettingsHUD.tscn")
const DIFFICULTY = GlobalVariables.DIFFICULTY
const DIFFICULTY_STRINGS = GlobalVariables.DIFFICULTY_STRINGS

func _ready():
	_resize_container()
	_update_hscore()
	_update_difficulty_label()
	$HUD_Container/VersionLabel.text = GlobalVariables.GAME_VERSION

func _resize_container():
	# I actually have no idea how this works
	# Thanks to kleonc (https://github.com/godotengine/godot/issues/49887)
	var window_to_root = Transform2D.IDENTITY.scaled(get_tree().root.size / OS.window_size)
	var safe_area_root = window_to_root.xform(OS.get_window_safe_area())
	var control = $HUD_Container
	assert(control.get_viewport() == get_tree().root, "Assumption: control is not in a nested Viewport")
	var parent_to_root = control.get_viewport_transform() * control.get_global_transform() * control.get_transform().affine_inverse()
	var root_to_parent = parent_to_root.affine_inverse()
	var safe_area_relative_to_parent = root_to_parent.xform(safe_area_root)
	control.rect_position = safe_area_relative_to_parent.position
	control.rect_size = safe_area_relative_to_parent.size

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
