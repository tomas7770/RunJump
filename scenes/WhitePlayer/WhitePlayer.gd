extends Player

var plat_color = Color("#7f7f7f")

var gravity = 1500
var pull_depth = 100
var pull_time = 0.5
var unpull_time = 0.2
var jump_force = 1.5
var jumping = false
var platforms
onready var platforms_tween = $PlatformsTween

var _first_frame = true

func inject_platforms_node(platforms_node):
	platforms = platforms_node

func _on_physics_process(delta):
	if _first_frame:
		# Hack to prevent player velocity from exploding due to collision velocity
		# being extreme in the first frame
		_first_frame = false
		return
	velocity.y += delta * gravity
	velocity = move_and_collide_wrap(velocity, Vector2(0,-1))

func move_and_collide_wrap(linear_velocity, up_direction):
	var collision = body.move_and_collide(linear_velocity*get_physics_process_delta_time())
	if collision:
		last_collision = collision
		_is_on_floor = collision.normal.angle_to(up_direction) <= deg2rad(45)
		return Vector2(0, collision.collider_velocity.y*jump_force)
	else:
		_is_on_floor = false
		return linear_velocity

func _on_jump_start():
	if jumping:
		return
	jumping = true
	platforms_tween.interpolate_property(platforms, "position:y", 0, pull_depth, pull_time,
		Tween.TRANS_SINE, Tween.EASE_OUT)
	platforms_tween.start()

func _on_jump_release():
	if !jumping:
		return
	jumping = false
	platforms_tween.remove_all()
	platforms_tween.interpolate_property(platforms, "position:y", null, 0, unpull_time,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	platforms_tween.start()
	if !(GlobalVariables.sound_mute):
		if GlobalVariables.sound_shift:
			$JumpSound.set_pitch_scale(rand_range(0.8,1.25))
		else:
			$JumpSound.set_pitch_scale(1.0)
		$JumpSound.play()

func _unhandled_input(event):  
	if event is InputEventMouseButton:  
		if event.pressed:  
			_on_jump_start()
		if !(event.pressed):
			_on_jump_release()
