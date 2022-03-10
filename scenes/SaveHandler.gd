extends Node

enum SAVE_VERSION {UNKNOWN = -1, LEGACY, v_0_4_0}
const LATEST_SAVE_VERSION = SAVE_VERSION.v_0_4_0
const SAVE_PATH = "user://savegame.save"

const METADATA_SECTION = "MetaData"
const SCORE_SECTION = "HighScores"
const UNLOCK_SECTION = "Unlockable"
const CONFIG_SECTION = "Config"

const LEGACY_HIGHSCORE_KEY = "high"
const OLD_SAVEABLE = {"high_score":LEGACY_HIGHSCORE_KEY, "sound_mute":"mute", "sound_shift":"sfxshift"}

const DIFFICULTY = GlobalVariables.DIFFICULTY
const CHARACTER = GlobalVariables.CHARACTER

# Locked by default in case something goes wrong while/before identifying the save version
var save_locked = true

func _identify_save_version(config):
	if !config.has_section_key(METADATA_SECTION, "save_version"):
		# Possibly LEGACY
		return _identify_legacy_save()
	var save_version = config.get_value("MetaData", "save_version")
	if typeof(save_version) != TYPE_INT \
	or save_version > LATEST_SAVE_VERSION or save_version < -1:
		return SAVE_VERSION.UNKNOWN
	return save_version

func _identify_legacy_save():
	var save_keys = OLD_SAVEABLE.values()
	var save_game = File.new()
	save_game.open(SAVE_PATH, File.READ)
	var already_parsed_line = false
	while not save_game.eof_reached():
		var unparsed_line = save_game.get_line()
		if unparsed_line == "":
			continue
		if already_parsed_line:
			save_game.close()
			return SAVE_VERSION.UNKNOWN
		var current_line = parse_json(unparsed_line)
		if current_line:
			already_parsed_line = true
			for key in current_line:
				if !(save_keys.has(key)):
					save_game.close()
					return SAVE_VERSION.UNKNOWN
		else:
			return SAVE_VERSION.UNKNOWN
	save_game.close()
	return SAVE_VERSION.LEGACY

func _load_legacy_highscores():
	var save_game = File.new()
	save_game.open(SAVE_PATH, File.READ)
	while not save_game.eof_reached():
		var unparsed_line = save_game.get_line()
		if unparsed_line == "":
			continue
		var currentline = parse_json(unparsed_line)
		if currentline and currentline.has(LEGACY_HIGHSCORE_KEY):
			var saved_data = currentline[LEGACY_HIGHSCORE_KEY]
			if typeof(saved_data) == TYPE_REAL:
				# Pre-v0.3.0
				GlobalVariables.high_score[CHARACTER.ORANGE][DIFFICULTY.NORMAL] = saved_data
			else:
				# v0.3.0
				# Need to cast JSON string keys to integer (enum)
				for difficulty_key in saved_data:
					GlobalVariables.high_score[CHARACTER.ORANGE][int(difficulty_key)] \
					= saved_data[difficulty_key]
	save_game.close()

func _score_key(character_x, difficulty_x):
	return str(character_x)+"_"+str(difficulty_x)

func load_data():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err != OK:
		# Didn't load
		if err == ERR_FILE_NOT_FOUND:
			save_locked = false
		return
	var save_version = _identify_save_version(config)
	save_locked = false
	match save_version:
		SAVE_VERSION.LEGACY:
			return _load_legacy_highscores()
		SAVE_VERSION.v_0_4_0:
			for character_x in CHARACTER.values():
				for difficulty_x in DIFFICULTY.values():
					var high_score_x = config.get_value(SCORE_SECTION, \
					_score_key(character_x, difficulty_x), GlobalVariables.high_score[character_x][difficulty_x])
					GlobalVariables.highscore_set(high_score_x, character_x, difficulty_x, false)
			var saved_unlocked_characters = config.get_value(UNLOCK_SECTION, "unlocked_characters", \
											GlobalVariables.unlocked_characters)
			for character_x in saved_unlocked_characters:
				if !GlobalVariables.unlocked_characters.has(character_x):
					GlobalVariables.unlocked_characters.append(character_x)
			GlobalVariables.sound_mute = config.get_value(CONFIG_SECTION, "sound_mute", GlobalVariables.sound_mute)
			GlobalVariables.sound_shift = config.get_value(CONFIG_SECTION, "sound_shift", GlobalVariables.sound_shift)
			GlobalVariables.music_enabled = config.get_value(CONFIG_SECTION, "music_enabled", GlobalVariables.music_enabled)
			GlobalVariables.interpolation_set(config.get_value(CONFIG_SECTION, "interpolation", \
											GlobalVariables.interpolation), false)
		_:
			# Unknown
			# Warn about it and prevent overwriting
			# TitleHUD will check for save_locked
			save_locked = true

func save_data():
	if save_locked:
		return
	var config = ConfigFile.new()
	config.set_value(METADATA_SECTION, "save_version", LATEST_SAVE_VERSION)
	for character_x in CHARACTER.values():
		for difficulty_x in DIFFICULTY.values():
			var high_score_x = GlobalVariables.high_score[character_x][difficulty_x]
			config.set_value(SCORE_SECTION, _score_key(character_x, difficulty_x), int(high_score_x))
	config.set_value(UNLOCK_SECTION, "unlocked_characters", GlobalVariables.unlocked_characters)
	config.set_value(CONFIG_SECTION, "sound_mute", GlobalVariables.sound_mute)
	config.set_value(CONFIG_SECTION, "sound_shift", GlobalVariables.sound_shift)
	config.set_value(CONFIG_SECTION, "music_enabled", GlobalVariables.music_enabled)
	config.set_value(CONFIG_SECTION, "interpolation", GlobalVariables.interpolation)
	config.save(SAVE_PATH)
