extends Player
class_name GreenPlayer

enum JUMP_ANIM_STATE {FREE, HIGH_WAIT, LOW_WAIT}

var gravity = 2000
var jump_velocity = 1200
var stop_jump_factor = 0.35
var land_particles_speed_threshold = 1000
var canJump = false
var has_jumped = false
var has_dropped_off = false
var has_landed = true
onready var anim_player = $AnimationPlayer
var jump_anim_state = JUMP_ANIM_STATE.FREE

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_animations()

func _load_animations():
	# Load animations for player classes based on this one
	var jump_anim = load("res://animations/Player/JumpAnim.tres")
	var fall_anim = load("res://animations/Player/FallAnim.tres")
	anim_player.add_animation("JumpAnim", jump_anim)
	anim_player.add_animation("FallAnim", fall_anim)

func _on_physics_process(delta):
	velocity.y += delta * gravity
	var prev_velocity = velocity
	velocity = body.move_and_slide(velocity,Vector2(0,-1))
	if velocity:
		# On air
		canJump = false
		has_landed = false
		if velocity.y > 0 and !has_jumped:
			if !has_dropped_off:
				jump_anim_state = JUMP_ANIM_STATE.FREE
				anim_player.play("FallAnim")
			has_dropped_off = true
		if velocity.y > 0 and jump_anim_state == JUMP_ANIM_STATE.HIGH_WAIT:
			jump_anim_state = JUMP_ANIM_STATE.FREE
			anim_player.play()
	else:
		# On floor
		canJump = true
		has_jumped = false
		has_dropped_off = false
		if !has_landed:
			if prev_velocity.y >= land_particles_speed_threshold:
				_emit_land_particles()
			has_landed = true
		if jump_anim_state == JUMP_ANIM_STATE.LOW_WAIT:
			jump_anim_state = JUMP_ANIM_STATE.FREE
			anim_player.play()

func _emit_land_particles():
	for i in body.get_slide_count():
		var collision = body.get_slide_collision(i)
		var collider = collision.collider
		if collider.get_parent() is Platform:
			collider.get_parent().emit_land_particles(body.global_position + Vector2(0,64))

func _on_jump_start():
	velocity.y -= jump_velocity
	has_jumped = true
	anim_player.stop()
	anim_player.play("JumpAnim")
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

# Animation freezes at a certain keyframe while jumping
func _on_jumpanim_high_reached():
	if velocity.y < 0:
		anim_player.stop(false)
		jump_anim_state = JUMP_ANIM_STATE.HIGH_WAIT

# Animation freezes at a certain keyframe while falling
func _on_jumpanim_low_reached():
	if velocity.y > 0:
		anim_player.stop(false)
		jump_anim_state = JUMP_ANIM_STATE.LOW_WAIT
