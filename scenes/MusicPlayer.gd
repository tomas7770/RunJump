extends Node

func _ready():
	var music = AudioStreamPlayer.new()
	add_child(music)
	music.stream = load("res://sounds/music/fasttheme.mp3")
	music.play()
