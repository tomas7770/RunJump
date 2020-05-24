extends StaticBody2D

#var speed = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#func _physics_process(delta):
#	pass

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
