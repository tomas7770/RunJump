extends Node2D

var bodyposition setget _set_body_position, _get_body_position
var bodyscale setget _set_body_scale, _get_body_scale
onready var body = $Body

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(_delta):
	$Sprite.position = body.position

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _set_body_position(pos):
	body.position = pos

func _get_body_position():
	return body.position

func _set_body_scale(new_scale):
	body.scale = new_scale
	$Sprite.scale = new_scale

func _get_body_scale():
	return body.scale
