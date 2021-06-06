extends CanvasLayer

onready var main_settings = $MainSettings
onready var settings_list = $MainSettings/ScrollContainer/VBoxContainer
onready var color_settings = $ColorSettings
onready var color_picker = $ColorSettings/ColorPicker

func _ready():
	update_mute(GlobalVariables.sound_mute)
	update_sfxshift(GlobalVariables.sound_shift)
	main_settings.popup()

func update_mute(muted):
	if muted:
		settings_list.get_node("MuteButton").text = str("Sound Off")
	else:
		settings_list.get_node("MuteButton").text = str("Sound On")

func update_sfxshift(enabled):
	if enabled:
		settings_list.get_node("SFXShiftButton").text = str("Pitch Shift On")
	else:
		settings_list.get_node("SFXShiftButton").text = str("Pitch Shift Off")

func _on_MuteButton_pressed():
	var isMuted = GlobalVariables.sound_mute
	GlobalVariables.mute_set(!isMuted)
	update_mute(!isMuted)

func _on_SFXShiftButton_pressed():
	var isShift = GlobalVariables.sound_shift
	GlobalVariables.sfxshift_set(!isShift)
	update_sfxshift(!isShift)

func _on_CloseButton_pressed():
	queue_free()

func _on_ColorButton_pressed():
	color_settings.popup()
	main_settings.hide()

func _on_BackButton_pressed():
	main_settings.popup()
	color_settings.hide()

func _on_ColorPicker_color_changed(color):
	VisualServer.set_default_clear_color(color)

func _on_DefaultButton_pressed():
	var color = ProjectSettings.get_setting("rendering/environment/default_clear_color")
	color_picker.set_pick_color(color)
	VisualServer.set_default_clear_color(color)
