extends CanvasLayer

onready var main_settings = $HUD_Container/MainSettings
onready var settings_list = $HUD_Container/MainSettings/ScrollContainer/VBoxContainer
onready var color_settings = $HUD_Container/ColorSettings
onready var color_picker = $HUD_Container/ColorSettings/ColorPicker
onready var adv_settings = $HUD_Container/AdvSettings

func _ready():
	GlobalVariables.resize_control_toSafeArea($HUD_Container)
	update_mute(GlobalVariables.sound_mute)
	update_sfxshift(GlobalVariables.sound_shift)
	main_settings.get_node("VersionLabel").text = GlobalVariables.GAME_VERSION
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
	if muted:
		button.set_pressed_no_signal(false)
	else:
		button.set_pressed_no_signal(true)

func update_sfxshift(enabled):
	var button = settings_list.get_node("SFXShiftContainer").get_node("CheckButton")
	if enabled:
		button.set_pressed_no_signal(true)
	else:
		button.set_pressed_no_signal(false)

func _submenu_open():
	return color_settings.visible or adv_settings.visible

func _on_MuteButton_toggled(button_pressed):
	GlobalVariables.mute_set(!button_pressed)

func _on_SFXShiftButton_toggled(button_pressed):
	GlobalVariables.sfxshift_set(button_pressed)

func _on_CloseButton_pressed():
	queue_free()

func _on_ColorButton_pressed():
	color_settings.popup()
	main_settings.hide()

func _on_AdvButton_pressed():
	adv_settings.popup()
	main_settings.hide()

func _on_BackButton_pressed():
	main_settings.popup()
	color_settings.hide()
	adv_settings.hide()

func _on_ColorPicker_color_changed(color):
	VisualServer.set_default_clear_color(color)

func _on_DefaultButton_pressed():
	var color = ProjectSettings.get_setting("rendering/environment/default_clear_color")
	color_picker.set_pick_color(color)
	VisualServer.set_default_clear_color(color)
