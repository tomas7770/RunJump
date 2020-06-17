#warning-ignore:return_value_discarded
extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _unhandled_input(event):  
	if event is InputEventMouseButton:  
		if event.pressed:
			get_tree().change_scene("res://scenes/Main.tscn")
