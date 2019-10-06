extends Node2D

signal done_expanding(expanded)

var bfs_discovered: = {}
var expanded: = {}
var started: = false

func _ready():
	pass
	# start();
	
func try_find_circle(corners:Array) -> bool:
	var queue: = [Vector2(0,0)]
	bfs_discovered = {}
	while not queue.empty():
		var v:Vector2 = queue.pop_front()
		for w in [v + Vector2(1,0), v + Vector2(0,1),v - Vector2(1,0),v - Vector2(0,1)]:
			if corners.has(w):
				# Found a corner,
				return false
			if bfs_discovered.has(w):
				continue
			bfs_discovered[w] = true
			if $"../Env".has_wall(w):
				continue
			queue.push_back(w)
			
	return true
	

func start():
	if started:
		return
		
	if not try_find_circle($"../Env".get_corners()):
		return
	
	started = true
	
	expanded = {}
	expand_to(Vector2.ZERO)
	expand()
	$ExpandTimer.start()

func expand_to(coords:Vector2) -> bool:
	if expanded.has(coords) or not bfs_discovered.has(coords):
		# Already expanded this tile.
		return false
		
	# If has a wall, mark as expanded so we do not expand again.
	expanded[coords] = $"../Env".has_wall(coords)
	add_white(coords)
	return true
	
func add_white(coords:Vector2):
	var white:Sprite = preload("res://White.tscn").instance()
	white.position = Env.coords_to_pos(coords)
	add_child(white)

func expand() -> bool:
	var did_expand: = false
	for coords in expanded.keys():
		if expanded[coords]:
			continue
		for v in [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]:
			if (expand_to(coords + v)):
				did_expand = true
	
	if did_expand:
		# Schedule another expansion
		$ExpandTimer.start()
		
	return did_expand

func _on_ExpandTimer_timeout():
	if expand():
		return
	
	started = false
	
	for child in get_children():
		if child is Sprite:
			child.queue_free()
	
	emit_signal("done_expanding", expanded)
		
