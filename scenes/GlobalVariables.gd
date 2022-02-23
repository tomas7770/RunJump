extends Node

signal on_pause

const GAME_VERSION = "Dev Version (v0.3.0+)"
enum DIFFICULTY {NORMAL, EASY, FAST}
const DIFFICULTY_STRINGS = {
	DIFFICULTY.NORMAL:"Normal",
	DIFFICULTY.EASY:"Easy",
	DIFFICULTY.FAST:"Fast"
}
enum CHARACTER {GREEN, ORANGE, RED, BLUE}
const CHARACTER_STRINGS = {
	CHARACTER.GREEN:"Green",
	CHARACTER.ORANGE:"Orange",
	CHARACTER.RED:"Red",
	CHARACTER.BLUE:"Blue",
}
const CHARACTER_SCENES = {
	CHARACTER.GREEN:"GreenPlayer",
	CHARACTER.ORANGE:"OrangePlayer",
	CHARACTER.RED:"RedPlayer",
	CHARACTER.BLUE:"BluePlayer",
}
var SaveHandler
var high_score = {}
var sound_mute = false
var sound_shift = false
var interpolation = true setget interpolation_set
var selected_difficulty = DIFFICULTY.NORMAL
var selected_character = CHARACTER.GREEN
# warning-ignore:unused_class_variable
var pause = false setget pause_set

# Called when the node enters the scene tree for the first time.
func _ready():
	var SaveHandlerClass = load("res://scenes/SaveHandler.gd")
	SaveHandler = SaveHandlerClass.new()
	add_child(SaveHandler)
	# Fill default high scores
	for character_x in CHARACTER.values():
		high_score[character_x] = {}
		for difficulty_x in DIFFICULTY.values():
			high_score[character_x][difficulty_x] = 0
	SaveHandler.load_data()

func highscore_set(val, played_character, played_difficulty):
	if val > high_score[played_character][played_difficulty]:
		high_score[played_character][played_difficulty] = val
		SaveHandler.save_data()

func highscore_get():
	return high_score[selected_character][selected_difficulty]

func mute_set(val):
	sound_mute = val
	SaveHandler.save_data()

func sfxshift_set(val):
	sound_shift = val
	SaveHandler.save_data()

func interpolation_set(enable):
	assert(typeof(enable) == TYPE_BOOL)
	interpolation = enable
	if enable:
		Engine.physics_jitter_fix = 0
	else:
		Engine.physics_jitter_fix = 0.5

func pause_set(val):
	pause = val
	emit_signal("on_pause", pause)

func resize_control_toSafeArea(control):
	# Resizes a fullscreen Control to fit window safe area
	# I actually have no idea how this works
	# Thanks to kleonc (https://github.com/godotengine/godot/issues/49887)
	var window_to_root = Transform2D.IDENTITY.scaled(get_tree().root.size / OS.window_size)
	var safe_area_root = window_to_root.xform(OS.get_window_safe_area())
	assert(control.get_viewport() == get_tree().root, "Assumption: control is not in a nested Viewport")
	var parent_to_root = control.get_viewport_transform() * control.get_global_transform() * control.get_transform().affine_inverse()
	var root_to_parent = parent_to_root.affine_inverse()
	var safe_area_relative_to_parent = root_to_parent.xform(safe_area_root)
	control.rect_position = safe_area_relative_to_parent.position
	control.rect_size = safe_area_relative_to_parent.size

func _exit_tree():
	SaveHandler.save_data()

func next_difficulty():
	selected_difficulty = (selected_difficulty+1)%(DIFFICULTY.size())

func next_character():
	selected_character = (selected_character+1)%(CHARACTER.size())

func load_character_scene(character):
	var scene_name = CHARACTER_SCENES[character]
	var player_scene = load("res://scenes/"+scene_name+"/"+scene_name+".tscn")
	return player_scene

func is_save_locked():
	return SaveHandler.save_locked
