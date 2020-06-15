#warning-ignore:return_value_discarded
extends Node2D

export (PackedScene) var Platform
export var speed = 200
onready var player = get_node("Player")
var screen_size
var score
var last_height = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = Vector2(480,854)
	new_game()

func new_game():
	score = 0
	speed = 200
	last_height = 3
	$HUD.update_score(score)
	player.position = Vector2(128,598)
	var plats = get_tree().get_nodes_in_group("Platforms")
	for platX in plats:
		platX.queue_free()
	randomize()
	var plat = Platform.instance()
	add_child(plat)
	plat.scale = Vector2(8,3)
	plat.position = Vector2(32*plat.scale.x,screen_size.y-32*plat.scale.y)
	$SpawnTimer.set_paused(false)
	$ScoreTimer.set_paused(false)
	$SpawnTimer.start(1.5)
	$ScoreTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !(GlobalVariables.pause):
		if player.position.y-64 > screen_size.y:
			GlobalVariables.pause = true
			$Player.queue_free()
			GlobalVariables.highscore_set(score)
			$HUD.game_over()
		if $SpawnTimer.is_paused() or $ScoreTimer.is_paused():
			$SpawnTimer.set_paused(false)
			$ScoreTimer.set_paused(false)
	elif !($SpawnTimer.is_paused()) or !($ScoreTimer.is_paused()):
		$SpawnTimer.set_paused(true)
		$ScoreTimer.set_paused(true)

func _physics_process(delta):
	if !(GlobalVariables.pause):
		var plats = get_tree().get_nodes_in_group("Platforms")
		for platX in plats:
			platX.position.x -= speed*delta

func _on_SpawnTimer_timeout():
	var plat = Platform.instance()
	add_child(plat)
	plat.scale = Vector2(1+randi()%5,min(1+randi()%5,last_height+3)) # 1-5
	last_height = plat.scale.y
	plat.position = Vector2(screen_size.x+32*plat.scale.x,screen_size.y-32*plat.scale.y)
	$SpawnTimer.start(plat.scale.x/(2.0*(speed/200.0)))

func _on_ScoreTimer_timeout():
	score += 1
	speed += 2
	$HUD.update_score(score)

func _exit_tree():
	GlobalVariables.highscore_set(score)
