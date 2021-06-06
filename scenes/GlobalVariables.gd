extends Node

const GAME_VERSION = "Development Version (v0.2.2+)"
const SAVEABLE = {"high_score":"high", "sound_mute":"mute", "sound_shift":"sfxshift"}
enum DIFFICULTY {NORMAL, EASY}
var high_score = {}
var sound_mute = false
var sound_shift = false
var selected_difficulty = DIFFICULTY.NORMAL
# warning-ignore:unused_class_variable
var pause = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Fill default high scores
	for value in DIFFICULTY.values():
		high_score[value] = 0
	load_data()

func highscore_set(val, played_difficulty):
	if val > high_score[played_difficulty]:
		high_score[played_difficulty] = val
		save_data()

func highscore_get():
	return high_score[selected_difficulty]

func mute_set(val):
	sound_mute = val
	save_data()

func sfxshift_set(val):
	sound_shift = val
	save_data()

func save_data():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var save_dict = {}
	for key in SAVEABLE:
		save_dict[SAVEABLE[key]] = self[key]
	save_game.store_line(to_json(save_dict))
	save_game.close()

func load_data():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open("user://savegame.save", File.READ)
	while not save_game.eof_reached():
		var unparsed_line = save_game.get_line()
		if unparsed_line == "":
			continue
		var currentline = parse_json(unparsed_line)
		if currentline:
			for key in SAVEABLE:
				var value = SAVEABLE[key]
				if currentline.has(value):
					var saved_data = currentline[value]
					if value == "high":
						if typeof(saved_data) == TYPE_REAL:
							# Backwards compatibility with older saves
							high_score[DIFFICULTY.NORMAL] = saved_data
							continue
						else:
							# Need to cast JSON string keys to integer (enum)
							for difficulty_key in saved_data:
								high_score[int(difficulty_key)] = saved_data[difficulty_key]
							continue
					self[key] = saved_data
	save_game.close()

func _exit_tree():
	save_data()
