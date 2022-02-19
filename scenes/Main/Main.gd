#warning-ignore:return_value_discarded
extends Control

const DIFFICULTY = GlobalVariables.DIFFICULTY
export (PackedScene) var Platform
export var initial_speed = 250
export var default_speed_increment = 2
export var initial_height = 3
export var distance_scale = 200.0
onready var player = get_node("Player")
var screen_size = Vector2(480,854)
var score
var speed
var last_height
var current_difficulty

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

func _get_next_plat_size():
	match current_difficulty:
		DIFFICULTY.NORMAL, DIFFICULTY.FAST:
			return Vector2(1+randi()%5, min(1+randi()%5, last_height+3)) # 1-5
		DIFFICULTY.EASY:
			var width
			var height
			var possible_heights = []
			for i in range(1,6):
				# Can't spawn two consecutive plats with same height
				if i != last_height:
					possible_heights.append(i)
			height = clamp(possible_heights[randi()%possible_heights.size()], last_height-2, last_height+3)
			if 1+randi()%5 == height:
				# Next plat would have the same height, assuming no restrictions
				width = 5
			else:
				if randi()%7 == 0: # 1/7 chance, half the chance of other values
					width = 2
				else: # 6/7 chance, 2/7 for each possible value
					width = 3+randi()%3
			return Vector2(width, height)

func _get_speed_increment():
	match current_difficulty:
		DIFFICULTY.FAST:
			return default_speed_increment*2
		_:
			return default_speed_increment

func new_game():
	score = 0
	speed = initial_speed
	last_height = initial_height
	current_difficulty = GlobalVariables.selected_difficulty
	$HUD.update_score(score)
	$HUD.update_difficulty_label(current_difficulty)
	$HUD.update_highscore_label(GlobalVariables.highscore_get())
	player.bodyposition = Vector2(128,598)
	player.reset_interpolation()
	var plats = get_tree().get_nodes_in_group("Platforms")
	for platX in plats:
		platX.queue_free()
	randomize()
	var plat = Platform.instance()
	add_child(plat)
	plat.bodyscale = Vector2(8,initial_height)
	plat.bodyposition = Vector2(32*plat.bodyscale.x,screen_size.y-32*plat.bodyscale.y)
	plat.reset_interpolation()
	$SpawnTimer.set_paused(false)
	$ScoreTimer.set_paused(false)
	$SpawnTimer.start(1.5*distance_scale/speed)
	$ScoreTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !(GlobalVariables.pause):
		if player.bodyposition.y-64 > screen_size.y:
			GlobalVariables.pause = true
			$Player.queue_free()
			var old_highscore = GlobalVariables.highscore_get()
			if score > old_highscore:
				$HUD.newhighscore(old_highscore, score)
			GlobalVariables.highscore_set(score, current_difficulty)
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
			platX.bodyposition.x -= speed*delta

func _on_SpawnTimer_timeout():
	var plat = Platform.instance()
	add_child(plat)
	plat.bodyscale = _get_next_plat_size()
	last_height = plat.bodyscale.y
	plat.bodyposition = Vector2(screen_size.x+32*plat.bodyscale.x,screen_size.y-32*plat.bodyscale.y)
	plat.reset_interpolation()
	$SpawnTimer.start(plat.bodyscale.x/(2.0*(speed/distance_scale)))

func _on_ScoreTimer_timeout():
	score += 1
	speed += _get_speed_increment()
	$HUD.update_score(score)

func _exit_tree():
	GlobalVariables.highscore_set(score, current_difficulty)
