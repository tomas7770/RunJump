#warning-ignore-all:return_value_discarded
extends Control

const LAYER_DIST = {
	"Layer1": 2,
	"Layer2": 4,
}
const LAYER_COLORS = {
	"Layer1": Color(0.44, 0.44, 0.44, 1.00),
	"Layer2": Color(0.24, 0.24, 0.24, 1.00),
}
const SCREEN_SIZE = GlobalVariables.SCREEN_SIZE
export (PackedScene) var BGPlat
var game_started = false
var main

func _ready():
	_on_bgplats_set(GlobalVariables.bg_plats)
	_generate_initial_plats()
	$Layer1/SpawnTimer.connect("timeout", self, "_on_SpawnTimer_timeout", [$Layer1/SpawnTimer])
	$Layer2/SpawnTimer.connect("timeout", self, "_on_SpawnTimer_timeout", [$Layer2/SpawnTimer])
	GlobalVariables.connect("on_bgplats_set", self, "_on_bgplats_set")

func _physics_process(delta):
	if game_started:
		var layers = get_children()
		for layer in layers:
			var layer_children = layer.get_children()
			for child in layer_children:
				if child.name != "SpawnTimer":
					child.bodyposition.x -= main.speed*delta/LAYER_DIST[layer.name]
					if child.sprite_is_offscreen():
						child.queue_free()

func on_game_start():
	main = get_parent()
	_start_timers()
	if game_started:
		# Restart
		_generate_initial_plats()
	else:
		game_started = true

func set_plat_color(color):
	var layers = get_children()
	for layer in layers:
		layer.modulate = color*LAYER_COLORS[layer.name]

func _generate_initial_plats():
	var layers = get_children()
	for layer in layers:
		var layer_children = layer.get_children()
		for child in layer_children:
			if child.name != "SpawnTimer":
				child.queue_free()
	for layer in layers:
		var x_pos = 0
		while x_pos < SCREEN_SIZE.x:
			var plat = _spawn_plat(layer)
			x_pos += 32*plat.bodyscale.x
			plat.bodyposition = Vector2(x_pos, SCREEN_SIZE.y-32*plat.bodyscale.y)
			plat.reset_interpolation()
			x_pos += 64*plat.bodyscale.x

func _start_timers():
	var layers = get_children()
	for layer in layers:
		var timer = layer.get_node("SpawnTimer")
		timer.start()

func _on_bgplats_set(enabled):
	$Layer1.visible = enabled
	$Layer2.visible = enabled

func _get_next_plat_size():
	return Vector2(1+randi()%5, 1+randi()%5) # 1-5

# Change plat size according to layer
func _transform_plat_size(plat_size, layer_name):
	plat_size.x /= LAYER_DIST[layer_name]
	plat_size.y += 5*LAYER_DIST[layer_name]/4
	return plat_size

func _spawn_plat(layer):
	var plat = BGPlat.instance()
	plat.set_color(Color(1.0, 1.0, 1.0, 1.0))
	layer.add_child(plat)
	var plat_size = _transform_plat_size(_get_next_plat_size(), layer.name)
	plat.bodyscale = plat_size
	return plat

func _on_SpawnTimer_timeout(timer):
	var layer = timer.get_parent()
	var plat = _spawn_plat(layer)
	plat.bodyposition = Vector2(SCREEN_SIZE.x+32*plat.bodyscale.x,SCREEN_SIZE.y-32*plat.bodyscale.y)
	plat.reset_interpolation()
	timer.start(LAYER_DIST[layer.name]*plat.bodyscale.x/(2.0*(main.speed/main.distance_scale)))
