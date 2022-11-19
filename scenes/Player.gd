extends Node2D
class_name Player

var velocity = Vector2()
var prevposition: Vector2
var bodyposition setget _set_body_position, _get_body_position
onready var body = $Body
var last_collision
var _is_on_floor = false

# Called when the node enters the scene tree for the first time.
func _ready():
	prevposition = body.position

func _process(_delta):
	if GlobalVariables.interpolation:
		$Sprite.position = prevposition.linear_interpolate(body.position, Engine.get_physics_interpolation_fraction())
	else:
		$Sprite.position = body.position

func _on_physics_process(_delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	prevposition = body.position
	_on_physics_process(delta)

func move_and_collide_wrap(linear_velocity, up_direction):
	var collision = body.move_and_collide(linear_velocity*get_physics_process_delta_time())
	if collision:
		last_collision = collision
		_is_on_floor = collision.normal.angle_to(up_direction) <= deg2rad(45)
		return Vector2.ZERO
	else:
		_is_on_floor = false
		return linear_velocity

func is_on_floor():
	return _is_on_floor

func _set_body_position(pos):
	body.position = pos

func _get_body_position():
	return body.position

func reset_interpolation():
	prevposition = body.position
