#warning-ignore:return_value_discarded
extends Control

const DIFFICULTY = GlobalVariables.DIFFICULTY
const CHARACTER = GlobalVariables.CHARACTER
const SCREEN_SIZE = GlobalVariables.SCREEN_SIZE
export (PackedScene) var Platform
export var initial_speed = 250
export var default_speed_increment = 2
export var speed_cap = 700
export var initial_height = 3
export var distance_scale = 200.0
# Use separate RNG to prevent game logic from being affected by other RNG calls
var rng = RandomNumberGenerator.new()
var player
var background
var force_plat_color
var score
var speed
var last_height
var current_difficulty
var current_character
var in_preparation
var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_add_player()
	_add_background()
	new_game()

func _add_player():
	var player_scene = GlobalVariables.load_character_scene(GlobalVariables.selected_character)
	player = player_scene.instance()
	if player.get("plat_color"):
		force_plat_color = player.plat_color
	add_child(player)
	move_child(player, 0)

func _add_background():
	background = GlobalVariables.passed_background
	add_child(background)
	background.on_game_start()

func _get_next_plat_size():
	match current_difficulty:
		DIFFICULTY.NORMAL, DIFFICULTY.FAST:
			return Vector2(1+rng.randi()%5, min(1+rng.randi()%5, last_height+3)) # 1-5
		DIFFICULTY.EASY:
			var width
			var height
			var possible_heights = []
			for i in range(1,6):
				# Can't spawn two consecutive plats with same height
				if i != last_height:
					possible_heights.append(i)
			height = clamp(possible_heights[rng.randi()%possible_heights.size()], last_height-2, last_height+3)
			if 1+rng.randi()%5 == height:
				# Next plat would have the same height, assuming no restrictions
				width = 5
			else:
				if rng.randi()%7 == 0: # 1/7 chance, half the chance of other values
					width = 2
				else: # 6/7 chance, 2/7 for each possible value
					width = 3+rng.randi()%3
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
	current_character = GlobalVariables.selected_character
	in_preparation = true
	$HUD.update_score(score)
	$HUD.update_difficulty_label(current_difficulty)
	$HUD.update_highscore_label(GlobalVariables.highscore_get())
	player.bodyposition = Vector2(128,598)
	player.reset_interpolation()
	var plats = get_tree().get_nodes_in_group("Platforms")
	for platX in plats:
		platX.queue_free()
	rng.randomize()
	var plat = Platform.instance()
	if force_plat_color:
		plat.set_color(force_plat_color)
	add_child(plat)
	plat.bodyscale = Vector2(8,initial_height)
	plat.bodyposition = Vector2(32*plat.bodyscale.x,SCREEN_SIZE.y-32*plat.bodyscale.y)
	plat.reset_interpolation()
	$SpawnTimer.set_paused(false)
	$SpawnTimer.start(1.5*distance_scale/speed)
	$PreparationTimer.start()

func _physics_process(delta):
	if !game_over:
		var plats = get_tree().get_nodes_in_group("Platforms")
		for platX in plats:
			platX.bodyposition.x -= speed*delta
		if player.bodyposition.y-64 > SCREEN_SIZE.y:
			game_over = true
			$SpawnTimer.stop()
			$ScoreTimer.stop()
			$PreparationTimer.stop()
			GlobalVariables.pause = true
			player.queue_free()
			var old_highscore = GlobalVariables.highscore_get()
			if score > old_highscore:
				$HUD.newhighscore(old_highscore, score)
			GlobalVariables.highscore_set(score, current_character, current_difficulty)
			$HUD.game_over()

func _on_SpawnTimer_timeout():
	var plat = Platform.instance()
	if force_plat_color:
		plat.set_color(force_plat_color)
	add_child(plat)
	plat.bodyscale = _get_next_plat_size()
	last_height = plat.bodyscale.y
	plat.bodyposition = Vector2(SCREEN_SIZE.x+32*plat.bodyscale.x,SCREEN_SIZE.y-32*plat.bodyscale.y)
	plat.reset_interpolation()
	$SpawnTimer.start(plat.bodyscale.x/(2.0*(speed/distance_scale)))

func _on_ScoreTimer_timeout():
	score += 1
	speed = min(speed+_get_speed_increment(), speed_cap)
	$HUD.update_score(score)

func _on_PreparationTimer_timeout():
	in_preparation = false
	$ScoreTimer.start()
	# Pause ScoreTimer if game paused, just in case...
	$ScoreTimer.set_paused(GlobalVariables.pause)

func _exit_tree():
	remove_child(background)
	GlobalVariables.highscore_set(score, current_character, current_difficulty)
