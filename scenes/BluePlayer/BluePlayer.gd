extends Node2D

var plat_color = Color("#001b96")

var energy_hud_scene = preload("res://scenes/EnergyHUD/EnergyHUD.tscn")
var energy_bar

var gravity = 2000
var initial_fly_velocity = 300
# fly_acceleration_upward: Acceleration when moving up
var fly_acceleration_upward = 600
# fly_acceleration_recovery: Acceleration when recovering from falling
var fly_acceleration_recovery = 3000
var max_fly_velocity = 600
# top_limit: Minimum distance from top of the game screen while flying
var top_limit = 0
var max_energy = 100.0
var velocity = Vector2()
var isFlying = false
var energy = max_energy setget _set_energy
var prevposition: Vector2
var bodyposition setget _set_body_position, _get_body_position
onready var body = $Body

func _ready():
	prevposition = body.position
	var energy_hud = energy_hud_scene.instance()
	get_parent().add_child(energy_hud)
	energy_bar = energy_hud.get_node("HUD_Container/ProgressBar")
	# warning-ignore:return_value_discarded
	GlobalVariables.connect("on_pause", self, "_on_pause")

func _process(_delta):
	if GlobalVariables.interpolation:
		$Sprite.position = prevposition.linear_interpolate(body.position, Engine.get_physics_interpolation_fraction())
	else:
		$Sprite.position = body.position

func _on_physics_process(delta):
	prevposition = body.position
	if !(GlobalVariables.pause):
		if isFlying:
			var fly_acceleration = fly_acceleration_recovery if velocity.y > 0 else fly_acceleration_upward
			velocity.y = max(velocity.y-fly_acceleration*delta, -max_fly_velocity)
			_set_energy(energy-20.0*delta)
			if energy <= 0.0:
				_set_energy(0.0)
				_stop_jump()
		else:
			velocity.y += delta * gravity
		velocity = body.move_and_slide(velocity,Vector2(0,-1))
		if body.position.y < top_limit:
			body.position.y = top_limit
		if body.is_on_floor():
			_set_energy(min(energy+20.0*delta, max_energy))

func _physics_process(delta):
	_on_physics_process(delta)

func _on_jump_start():
	if is_zero_approx(energy):
		return
	isFlying = true
	if velocity.y > -initial_fly_velocity:
		velocity.y = max(velocity.y-initial_fly_velocity, -initial_fly_velocity)
	$Sprite/Particles.emitting = true
	if !(GlobalVariables.sound_mute):
		if GlobalVariables.sound_shift:
			$JumpSound.set_pitch_scale(rand_range(2.0/3.0,1.5))
		else:
			$JumpSound.set_pitch_scale(1.0)
		$JumpSound.play()

func _on_jump_release():
	_stop_jump()

func _stop_jump():
	isFlying = false
	$Sprite/Particles.emitting = false
	$JumpSound.stop()
	$JumpSound.seek(-1)

func _on_pause(pause):
	if pause:
		# Hack to prevent particles from disappearing
		# and not resuming processing until emitting again
		$Sprite/Particles.emitting = true
	else:
		$Sprite/Particles.emitting = isFlying
	$Sprite/Particles.speed_scale = 0 if pause else 1

func _unhandled_input(event):  
	if !(GlobalVariables.pause):
		if event is InputEventMouseButton:  
			if event.pressed:  
				_on_jump_start()
			if !(event.pressed):
				_on_jump_release()

func _set_body_position(pos):
	body.position = pos

func _get_body_position():
	return body.position

func reset_interpolation():
	prevposition = body.position

func _set_energy(value):
	energy = value
	energy_bar.value = value/max_energy
