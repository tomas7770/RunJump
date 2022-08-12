#warning-ignore-all:return_value_discarded
extends Control

const LAYER_DIST = {
	"Layer1": 2,
	"Layer2": 4,
}
const SCREEN_SIZE = GlobalVariables.SCREEN_SIZE
export (PackedScene) var BGPlat
var main

func _ready():
	main = get_parent()
	_on_bgplats_set(GlobalVariables.bg_plats)
	$Layer1/SpawnTimer.connect("timeout", self, "_on_SpawnTimer_timeout", [$Layer1/SpawnTimer])
	$Layer2/SpawnTimer.connect("timeout", self, "_on_SpawnTimer_timeout", [$Layer2/SpawnTimer])
	GlobalVariables.connect("on_pause", self, "_on_pause")
	GlobalVariables.connect("on_bgplats_set", self, "_on_bgplats_set")

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

func _on_bgplats_set(enabled):
	$Layer1.visible = enabled
	$Layer2.visible = enabled

func _get_next_plat_size():
	return Vector2(1+randi()%5, 1+randi()%5) # 1-5

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
	plat.bodyposition = Vector2(SCREEN_SIZE.x+32*plat.bodyscale.x,SCREEN_SIZE.y-32*plat.bodyscale.y)
	plat.reset_interpolation()
	timer.start(LAYER_DIST[layer.name]*plat.bodyscale.x/(2.0*(main.speed/main.distance_scale)))
