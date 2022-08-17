extends Node

const track_list = [
	"res://sounds/music/fasttheme.mp3",
	"res://sounds/music/upbeatoverworld.mp3"
]

var current_track = 0
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
	current_track += 1
	if current_track > track_list.size()-1:
		current_track = 0
	music.stream = load(track_list[current_track])
	music.play()
