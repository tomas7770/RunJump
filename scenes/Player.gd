extends KinematicBody2D

const gravity = 1500
var velocity = Vector2()
var canJump = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !(GlobalVariables.pause):
		velocity.y += delta * gravity
		velocity = move_and_slide(velocity,Vector2(0,-1))
		if velocity:
			canJump = false
		else:
			canJump = true
	
func _unhandled_input(event):  
	if !(GlobalVariables.pause):
		if event is InputEventMouseButton:  
			if event.pressed and canJump:  
				velocity.y -= 1000
				if !(GlobalVariables.mute_get()):
					if GlobalVariables.sfxshift_get():
						$JumpSound.set_pitch_scale(rand_range(2.0/3.0,1.5))
					else:
						$JumpSound.set_pitch_scale(1.0)
					$JumpSound.play()
			if !(event.pressed):
				# Released key
				if velocity.y < 0:
					velocity.y *= 0.5
