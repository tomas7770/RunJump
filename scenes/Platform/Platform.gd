extends Node2D
class_name Platform

var prevposition: Vector2
var body_moved = false
var bodyposition setget _set_body_position, _get_body_position
var bodyscale setget _set_body_scale, _get_body_scale
onready var body = $Body
var particle_container

# This is used for background platforms
var destroy_on_hide = true

# Called when the node enters the scene tree for the first time.
func _ready():
	prevposition = body.position
	particle_container = get_node_or_null("ParticleContainer")
	if particle_container:
		_generate_right_particle_emitter()
		particle_container.modulate = $Sprite.modulate

func _process(_delta):
	if GlobalVariables.interpolation:
		$Sprite.position = prevposition.linear_interpolate(body.position, Engine.get_physics_interpolation_fraction())
	else:
		$Sprite.position = body.position
	# BG plats don't have particles so we have to check if it exists
	if particle_container:
		particle_container.position = $Sprite.position

func _physics_process(_delta):
	if body_moved:
		body_moved = false
	else:
		prevposition = body.position

func _on_VisibilityNotifier2D_screen_exited():
	if destroy_on_hide:
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
	$Sprite.position = body.position

func set_color(color):
	$Sprite.modulate = color
	if particle_container:
		particle_container.modulate = $Sprite.modulate

func _generate_right_particle_emitter():
	var land_particles_left = particle_container.get_node("LandParticlesLeft")
	var land_particles_right = land_particles_left.duplicate()
	land_particles_right.name = "LandParticlesRight"
	land_particles_right.direction.x = -land_particles_right.direction.x
	particle_container.add_child(land_particles_right)

func emit_land_particles(collision_pos):
	for land_particles in particle_container.get_children():
		var x_offset = -15
		if land_particles.name == "LandParticlesRight":
			x_offset = 15
		land_particles.position.x = collision_pos.x - land_particles.global_position.x + x_offset
		land_particles.position.y = collision_pos.y - land_particles.global_position.y + 4
		land_particles.emitting = true
