extends Control

const LAYER_DIST = {
	"Layer1": 2,
	"Layer2": 4,
}
export (PackedScene) var BGPlat
# Use separate RNG to avoid interfering with game logic
var rng = RandomNumberGenerator.new()
var main
var screen_size

func _ready():
	rng.randomize()
	main = get_parent()
	screen_size = main.screen_size
	# warning-ignore:return_value_discarded
	$Layer1/SpawnTimer.connect("timeout", self, "_on_SpawnTimer_timeout", [$Layer1/SpawnTimer])
	# warning-ignore:return_value_discarded
	$Layer2/SpawnTimer.connect("timeout", self, "_on_SpawnTimer_timeout", [$Layer2/SpawnTimer])
	# warning-ignore:return_value_discarded
	GlobalVariables.connect("on_pause", self, "_on_pause")

func _physics_process(delta):
	if !(GlobalVariables.pause):
		var layers = get_children()
		for layer in layers:
			var layer_children = layer.get_children()
			for child in layer_children:
				if child.name != "SpawnTimer":
					child.bodyposition.x -= main.speed*delta/LAYER_DIST[layer.name]

func _on_pause(pause):
	var layers = get_children()
	for layer in layers:
		var timer = layer.get_node("SpawnTimer")
		timer.set_paused(pause)

func _get_next_plat_size():
	return Vector2(1+rng.randi()%5, 1+rng.randi()%5) # 1-5

func _on_SpawnTimer_timeout(timer):
	var layer = timer.get_parent()
	var plat = BGPlat.instance()
	var force_plat_color = main.force_plat_color
	if force_plat_color:
		plat.set_color(force_plat_color)
	layer.add_child(plat)
	var plat_size = _get_next_plat_size()
	plat_size.x /= LAYER_DIST[layer.name]
	plat_size.y += 5*LAYER_DIST[layer.name]/4
	plat.bodyscale = plat_size
	plat.bodyposition = Vector2(screen_size.x+32*plat.bodyscale.x,screen_size.y-32*plat.bodyscale.y)
	plat.reset_interpolation()
	timer.start(LAYER_DIST[layer.name]*plat.bodyscale.x/(2.0*(main.speed/main.distance_scale)))
