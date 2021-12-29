extends CanvasLayer

enum DATA_MODE {IMPORT, EXPORT}
onready var main_settings = $HUD_Container/MainSettings
onready var settings_list = $HUD_Container/MainSettings/ScrollContainer/VBoxContainer
onready var color_settings = $HUD_Container/ColorSettings
onready var color_picker = $HUD_Container/ColorSettings/ColorPicker
onready var advanced_settings = $HUD_Container/AdvancedSettings
onready var file_dialog = $HUD_Container/FileDialog
var current_data_mode: int

func _ready():
	GlobalVariables.resize_control_toSafeArea($HUD_Container)
	update_mute(GlobalVariables.sound_mute)
	update_sfxshift(GlobalVariables.sound_shift)
	main_settings.get_node("VersionLabel").text = GlobalVariables.GAME_VERSION
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

func _on_BackButton_pressed(button_id):
	main_settings.popup()
	match button_id:
		0:
			color_settings.hide()
		1:
			advanced_settings.hide()

func _on_ColorPicker_color_changed(color):
	VisualServer.set_default_clear_color(color)

func _on_DefaultButton_pressed():
	var color = ProjectSettings.get_setting("rendering/environment/default_clear_color")
	color_picker.set_pick_color(color)
	VisualServer.set_default_clear_color(color)

func _on_AdvancedButton_pressed():
	advanced_settings.popup()

func _on_ImportButton_pressed():
	current_data_mode = DATA_MODE.IMPORT
	file_dialog.popup()
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.window_title = "Import save data"

func _on_ExportButton_pressed():
	current_data_mode = DATA_MODE.EXPORT
	file_dialog.popup()
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.window_title = "Export save data"

func _on_FileDialog_file_selected(path):
	match current_data_mode:
		DATA_MODE.IMPORT:
			GlobalVariables.import_save(path)
		DATA_MODE.EXPORT:
			GlobalVariables.export_save(path)
