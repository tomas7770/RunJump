extends Node2D
class_name Player

var velocity = Vector2()
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

func _on_physics_process(_delta):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	prevposition = body.position
	_on_physics_process(delta)

func _set_body_position(pos):
	body.position = pos

func _get_body_position():
	return body.position

func reset_interpolation():
	prevposition = body.position
