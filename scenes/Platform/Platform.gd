extends Node2D

var prevposition: Vector2
var body_moved = false
var bodyposition setget _set_body_position, _get_body_position
var bodyscale setget _set_body_scale, _get_body_scale
onready var body = $Body

# Called when the node enters the scene tree for the first time.
func _ready():
	prevposition = body.position

func _process(_delta):
	$Sprite.position = prevposition.linear_interpolate(body.position, Engine.get_physics_interpolation_fraction())

func _physics_process(_delta):
	if body_moved:
		body_moved = false
	else:
		prevposition = body.position

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Body_screen_exited():
	body.get_node("CollisionShape2D").set_deferred("disabled", true)

func _set_body_position(pos):
	prevposition = body.position
	body_moved = true
	body.position = pos

func _get_body_position():
	return body.position

func _set_body_scale(new_scale):
	body.scale = new_scale
	$Sprite.scale = new_scale

func _get_body_scale():
	return body.scale

func reset_interpolation():
	prevposition = body.position
