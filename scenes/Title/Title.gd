#warning-ignore:return_value_discarded
extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _unhandled_input(event):  
	if event is InputEventMouseButton:  
		if event.pressed:
			get_tree().change_scene("res://scenes/Main/Main.tscn")

func update_colors():
	var player_scene = GlobalVariables.load_character_scene(GlobalVariables.selected_character)
	var dummy_player = player_scene.instance()
	$Player/Sprite.self_modulate = dummy_player.get_node("Sprite").self_modulate
	if dummy_player.get("plat_color"):
		$Platform.set_color(dummy_player.plat_color)
	else:
		$Platform.set_color("#1f7f1f")
