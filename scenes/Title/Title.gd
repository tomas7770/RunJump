#warning-ignore:return_value_discarded
extends Control

const DEFAULT_PLAT_COLOR = Color("#1f7f1f")
var char_locked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _unhandled_input(event):  
	if char_locked:
		return
	if event is InputEventMouseButton:  
		if event.pressed:
			_start_game()

func _start_game():
	var background = $Background
	background.suspend_visibility_notifiers()
	remove_child(background)
	GlobalVariables.passed_background = background
	get_tree().change_scene("res://scenes/Main/Main.tscn")

func _update_colors():
	var player_scene = GlobalVariables.load_character_scene(GlobalVariables.selected_character)
	var dummy_player = player_scene.instance()
	$Player/Sprite.self_modulate = dummy_player.get_node("Sprite").self_modulate
	if dummy_player.get("plat_color"):
		$Platform.set_color(dummy_player.plat_color)
		$Background.set_plat_color(dummy_player.plat_color)
	else:
		$Platform.set_color(DEFAULT_PLAT_COLOR)
		$Background.set_plat_color(DEFAULT_PLAT_COLOR)

func update_character():
	char_locked = GlobalVariables.is_char_locked(GlobalVariables.selected_character)
	_update_colors()
