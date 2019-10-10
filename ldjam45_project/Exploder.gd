extends Node2D

signal done_expanding(expanded)

var bfs_discovered: = {}
var expanded: = {}
var closed: = {}
var started: = false
var done: = false

func _ready():
	pass
	# start();
	
func check_finish() -> void:
	if not done:
		return

	for white in get_tree().get_nodes_in_group("whites"):
		if (white as Sprite).modulate.a < 1:
			# Not all whites appeared yet.
			return
		
	for white in get_tree().get_nodes_in_group("whites"):
		white.queue_free()
		
	emit_signal("done_expanding", bfs_discovered)
	
	done = false
	started = false
	
func _process(delta):
	check_finish()
	
func try_find_circle(corners:Array) -> bool:
	var corner_reached: = false
	for corner in corners:
		if $"../Env".dist.has(corner):
			return false
	print("found circle!")
	
	bfs_discovered = {}
	for coords in $"../Env".dist.keys():
		for diff in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
			bfs_discovered[coords + diff] = true
	
	return true

func start():
	if started:
		return
		
	if not try_find_circle($"../Env".get_corners()):
		return
		
	SoundManager.play_random_sound(SoundManager.circle)
	
	started = true
	
	get_tree().paused = true
	$"../PauseEffectTimer".stop()
	
	for coords in $"../Env".dist.keys():
		if not $"../Env".has_wall(coords):
			add_white(coords)
	done = true

func add_white(coords:Vector2):
	var white:Sprite = preload("res://White.tscn").instance()
	white.position = Env.coords_to_pos(coords)
	white.modulate = Color("f1fffe")
	# add_child(white)
	add_child(white)