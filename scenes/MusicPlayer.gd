extends Node

const track_list = [
	"res://sounds/music/fasttheme.mp3",
	"res://sounds/music/upbeatoverworld.mp3",
	"res://sounds/music/wyver9_FastLevel.mp3",
]

var current_track = randi() % track_list.size()
var music

func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	music = AudioStreamPlayer.new()
	add_child(music)
	music.stream = load(track_list[current_track])
	music.connect("finished", self, "_on_finished")

func toggle_music(enabled):
	if enabled:
		music.play()
	else:
		music.stop()

func _on_finished():
	if !GlobalVariables.music_enabled:
		return
	
	current_track = randi() % track_list.size()
	music.stream = load(track_list[current_track])
	music.play()
