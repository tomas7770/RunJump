extends GreenPlayer

var plat_color = Color("#7f1f1f")

var raise_gravity = 1000
var fall_gravity = 5000
var jump_released = false

func _init():
	jump_velocity = 900

func _on_physics_process(delta):
	if velocity.y < 0 and !jump_released:
		gravity = raise_gravity
	else:
		gravity = fall_gravity
	._on_physics_process(delta)

func _on_jump_start():
	jump_released = false
	._on_jump_start()

func _on_jump_release():
	jump_released = true
