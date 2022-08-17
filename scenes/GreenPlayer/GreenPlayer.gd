extends Node2D
class_name GreenPlayer

var gravity = 2000
var jump_velocity = 1200
var stop_jump_factor = 0.35
var velocity = Vector2()
var canJump = false
var prevposition: Vector2
var bodyposition setget _set_body_position, _get_body_position
onready var body = $Body

# Called when the node enters the scene tree for the first time.
func _ready():
	prevposition = body.position

func _process(_delta):
	if GlobalVariables.interpolation:
		$Sprite.position = prevposition.linear_interpolate(body.position, Engine.get_physics_interpolation_fraction())
	else:
		$Sprite.position = body.position

func _on_physics_process(delta):
	prevposition = body.position
	
	velocity.y += delta * gravity
	velocity = body.move_and_slide(velocity,Vector2(0,-1))
	if velocity:
		canJump = false
	else:
		canJump = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	_on_physics_process(delta)

func _on_jump_start():
	velocity.y -= jump_velocity
	if !(GlobalVariables.sound_mute):
		if GlobalVariables.sound_shift:
			$JumpSound.set_pitch_scale(rand_range(2.0/3.0,1.5))
		else:
			$JumpSound.set_pitch_scale(1.0)
		$JumpSound.play()

func _on_jump_release():
	if velocity.y < 0:
		velocity.y *= stop_jump_factor

func _unhandled_input(event):  
	if event is InputEventMouseButton:  
		if event.pressed and canJump:  
			_on_jump_start()
		if !(event.pressed):
			_on_jump_release()

func _set_body_position(pos):
	body.position = pos

func _get_body_position():
	return body.position

func reset_interpolation():
	prevposition = body.position
