extends CanvasLayer

onready var main_settings = $HUD_Container/MainSettings
onready var settings_list = $HUD_Container/MainSettings/ScrollContainer/VBoxContainer
onready var color_settings = $HUD_Container/ColorSettings
onready var color_picker = $HUD_Container/ColorSettings/ColorPicker
onready var adv_settings = $HUD_Container/AdvSettings
onready var adv_settings_list = $HUD_Container/AdvSettings/ScrollContainer/VBoxContainer
onready var credits = $HUD_Container/Credits
onready var error_dialog = $HUD_Container/ErrorDialog
onready var error_label = $HUD_Container/ErrorDialog/Label
onready var error_label_save = $HUD_Container/ErrorDialog/Label2

func _ready():
	GlobalVariables.resize_control_toSafeArea($HUD_Container)
	update_mute(GlobalVariables.sound_mute)
	update_sfxshift(GlobalVariables.sound_shift)
	update_music(GlobalVariables.music_enabled)
	update_bg_plats(GlobalVariables.bg_plats)
	update_interp(GlobalVariables.interpolation)
	main_settings.get_node("VersionLabel").text = GlobalVariables.GAME_VERSION
	adv_settings.get_node("EngineVersionLabel").text = "Godot " + Engine.get_version_info()["string"]
	main_settings.popup()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST \
	or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if _submenu_open():
			_on_BackButton_pressed()
		else:
			_on_CloseButton_pressed()

func update_mute(muted):
	var button = settings_list.get_node("SoundContainer").get_node("CheckButton")
	button.set_pressed_no_signal(!muted)

func update_sfxshift(enabled):
	var button = settings_list.get_node("SFXShiftContainer").get_node("CheckButton")
	button.set_pressed_no_signal(enabled)

func update_music(enabled):
	var button = settings_list.get_node("MusicContainer").get_node("CheckButton")
	button.set_pressed_no_signal(enabled)

func update_bg_plats(enabled):
	var button = settings_list.get_node("BGContainer").get_node("CheckButton")
	button.set_pressed_no_signal(enabled)

func update_interp(enabled):
	adv_settings_list.get_node("InterpContainer").get_node("CheckButton").set_pressed_no_signal(enabled)

func _submenu_open():
	return color_settings.visible or adv_settings.visible

func _on_MuteButton_toggled(button_pressed):
	GlobalVariables.mute_set(!button_pressed)

func _on_SFXShiftButton_toggled(button_pressed):
	GlobalVariables.sfxshift_set(button_pressed)

func _on_MusicButton_toggled(button_pressed):
	GlobalVariables.musicenabled_set(button_pressed)

func _on_BGButton_toggled(button_pressed):
	GlobalVariables.bgplats_set(button_pressed)

func _on_InterpButton_toggled(button_pressed):
	GlobalVariables.interpolation_set(button_pressed)

func _on_CloseButton_pressed():
	queue_free()

func _on_ColorButton_pressed():
	color_settings.popup()
	main_settings.hide()

func _on_AdvButton_pressed():
	adv_settings.popup()
	main_settings.hide()

func _on_CreditsButton_pressed():
	credits.popup()
	main_settings.hide()

func _on_BackButton_pressed():
	main_settings.popup()
	color_settings.hide()
	adv_settings.hide()
	credits.hide()

func _on_ColorPicker_color_changed(color):
	VisualServer.set_default_clear_color(color)

func _on_DefaultButton_pressed():
	var color = ProjectSettings.get_setting("rendering/environment/default_clear_color")
	color_picker.set_pick_color(color)
	VisualServer.set_default_clear_color(color)

func _on_ExportSaveButton_pressed():
	$HUD_Container/ExportDialog.popup()

func _on_ImportSaveButton_pressed():
	$HUD_Container/ImportDialog.popup()

func _on_AbortExportImportButton_pressed():
	$HUD_Container/ExportDialog.hide()
	$HUD_Container/ImportDialog.hide()
	$HUD_Container/ImportDialog2.hide()

func _on_ConfirmExportButton_pressed():
	$HUD_Container/ExportDialog.hide()
	var err = GlobalVariables.export_save()
	if err:
		error_label.text = "Error " + str(err)
		error_label_save.visible = false
		error_dialog.popup()

func _on_ConfirmImportButton_pressed():
	$HUD_Container/ImportDialog.hide()
	$HUD_Container/ImportDialog2.popup()

func _on_FinalConfirmImportButton_pressed():
	$HUD_Container/ImportDialog2.hide()
	var err = GlobalVariables.import_save()
	if err:
		if err == ERR_FILE_NOT_FOUND:
			error_label.text = "File not found!"
		else:
			error_label.text = "Error " + str(err)
		error_label_save.visible = true
		error_dialog.popup()
		return
	GlobalVariables.pause = false
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Title/Title.tscn")

func _on_ErrorCloseButton_pressed():
	error_dialog.hide()
