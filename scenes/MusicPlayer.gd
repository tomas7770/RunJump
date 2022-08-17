extends Node

var music

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	music = AudioStreamPlayer.new()
	add_child(music)
	music.stream = load("res://sounds/music/fasttheme.mp3")

func toggle_music(enabled):
	if enabled:
		music.play()
	else:
		music.stop()
