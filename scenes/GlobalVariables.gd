extends Node

const GAME_VERSION = "Development Version (v0.2.2+)"
var high_score = 0 setget highscore_set, highscore_get # Data ID 0
var sound_mute = false setget mute_set, mute_get # Data ID 1
var sound_shift = false setget sfxshift_set, sfxshift_get # Data ID 2
# warning-ignore:unused_class_variable
var pause = false

# Called when the node enters the scene tree for the first time.
func _ready():
	load_data()

func highscore_set(val):
	if val > high_score:
		high_score = val
		save_data()

func highscore_get():
	return high_score

func mute_set(val):
	sound_mute = val
	save_data()

func mute_get():
	return sound_mute

func sfxshift_set(val):
	sound_shift = val
	save_data()

func sfxshift_get():
	return sound_shift

func save_data():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json({high = high_score,mute = sound_mute,sfxshift = sound_shift}))
	save_game.close()

func load_data():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	while not save_game.eof_reached():
		var currentline = parse_json(save_game.get_line())
		if currentline:
			if currentline.has("high"):
				high_score = currentline["high"]
			else:
				high_score = 0
			
			if currentline.has("mute"):
				sound_mute = currentline["mute"]
			else:
				sound_mute = false
				
			if currentline.has("sfxshift"):
				sound_shift = currentline["sfxshift"]
			else:
				sound_shift = false
	save_game.close()
