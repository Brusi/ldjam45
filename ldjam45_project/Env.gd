extends Node2D

class_name Env

const SIZE = 20;

export(bool) var show_debug_path: = false

# Dictionary from Pos to Node.
var tiles = {}

const NEIGHBORS = [
	Vector2(-2, -1),
	Vector2(-2, 1),
	Vector2(-1, -2),
	Vector2(-1, -1),
	Vector2(-1, 0),
	Vector2(-1, 1),
	Vector2(-1, 2),
	Vector2(0, -1),
	Vector2(0, 1),
	Vector2(1, -2),
	Vector2(1, -1),
	Vector2(1, 0),
	Vector2(1, 1),
	Vector2(1, 2),
	Vector2(2, -1),
	Vector2(2, 1)]

func init_stam():
	add_wall(Vector2(1, 1))
	add_wall(Vector2(1, 2))
	add_wall(Vector2(1, 3))
	add_wall(Vector2(1, 4))
	add_wall(Vector2(-1, 1))
	add_wall(Vector2(-1, 2))
	add_wall(Vector2(-1, 3))
	add_wall(Vector2(-1, 4))
	add_wall(Vector2(-1, 4))
	add_wall(Vector2(-1, 2))
	add_wall(Vector2(1, 0))
	add_wall(Vector2(1, -1))
	add_wall(Vector2(1, -2))
	add_wall(Vector2(0, -2))
	add_wall(Vector2(-1, -2))
	add_wall(Vector2(-2, -2))
	add_wall(Vector2(-3, -2))
	add_wall(Vector2(-4, -2))
	add_wall(Vector2(-5, -2))
	add_wall(Vector2(-6, -2))
	add_wall(Vector2(-7, -2))
	add_wall(Vector2(-7, -2))

func _ready():
	dijkstra()
	pass
	
func add_wall_at(pos:Vector2):
	var wall = add_wall(pos_to_coords(pos))
	if wall == null:
		return null
	wall.position = pos
	return wall
	
func add_wall(coords:Vector2):
	if max(abs(coords.x), abs(coords.y)) >= 10:
		pass
		# Do not allow walls outside premise.
		#return null
	
	if coords == Vector2.ZERO:
		return null

	if tiles.has(coords):
		return tiles[coords]
	
	var wall: = preload("res://Wall.tscn").instance()
	wall.position = coords_to_pos(coords)
	$"..".add_child(wall)
	tiles[coords] = wall;
	
	dijkstra()
	
	return wall
	
func remove_wall(p:Vector2):
	if not tiles.has(p):
		return
	tiles[p].queue_free();
	tiles.erase(p)
	
static func pos_to_coords(vec:Vector2) -> Vector2:
	var p: = Vector2(int(round(vec.x / SIZE)), int(round(vec.y / SIZE)))
	return p

static func coords_to_pos(p:Vector2) -> Vector2:
	return Vector2(p.x, p.y) * SIZE;

const MAX_OPEN_SET: = 1000
const INFINITY: = 1000000.0

static func find_key_with_min_value(keys:Array, dict:Dictionary):
	var min_key = null;
	var min_value: = INFINITY
	for key in keys:
		if dict[key] < min_value:
			min_key = key
			min_value = dict[key]
	return min_key
	
func reconstruct_path(cameFrom, current):
    var total_path := [current]
    while current in cameFrom.keys():
        current = cameFrom[current]
        total_path.push_front(current)
    return total_path

func check_free_path(path:Array) -> bool:
	for i in range(path.size() - 1):
		if not check_free_way(path[i], path[i+1]):
			return false
	return true
		
func check_free_way(a:Vector2, b:Vector2) -> bool:
	var min_x:int = min(a.x, b.x)
	var max_x:int = max(a.x, b.x)
	
	var min_y:int = min(a.y, b.y)
	var max_y:int = max(a.y, b.y)
	
	for x in range(min_x, max_x+1):
		for y in range(min_y, max_y+1):
			if has_wall(Vector2(x,y)):
				return false
	return true
	
func has_wall(coords:Vector2) -> bool:
	return tiles.has(coords)
	
func has_wall_at(pos:Vector2) -> bool:
	return tiles.has(pos_to_coords(pos))
	
func get_wall_at(pos:Vector2) -> bool:
	return tiles[pos_to_coords(pos)]
	
func get_min_coords() -> Vector2:
	var min_coords: = Vector2.ZERO
	for wall_coords in tiles.keys():
		min_coords.x = min(min_coords.x, wall_coords.x)
		min_coords.y = min(min_coords.y, wall_coords.y)
	
	return min_coords
	
func get_max_coords() -> Vector2:
	var max_coords: = Vector2.ZERO
	for wall_coords in tiles.keys():
		max_coords.x = max(max_coords.x, wall_coords.x)
		max_coords.y = max(max_coords.y, wall_coords.y)
	
	return max_coords
	
func get_corners() -> Array:
	var min_coords = get_min_coords()
	var max_coords = get_max_coords()
	return [min_coords - Vector2(1, 1),
			max_coords + Vector2(1,1),
			Vector2(min_coords.x - 1, max_coords.y + 1),
			Vector2(max_coords.x + 1, min_coords.y - 1)]
			
var parent: = {}
var dist: = {}

func get_min_dist_coords(dist:Dictionary, queue:Array) -> Vector2:
	var min_dist: = INFINITY
	var min_coords:Vector2
	assert(not queue.empty())
	for coords in queue:
		assert (coords in dist)
		var coords_dist:float = dist[coords]
		if coords_dist < min_dist:
			min_dist = coords_dist
			min_coords = coords
			
	return min_coords
			

# Fills parent array with 'next target' for each tile coords.
func dijkstra():
	dist = {}
	parent = {}
	
	dist[Vector2.ZERO] = 0.0
	parent[Vector2.ZERO] = Vector2.ZERO
	
	var queue: = [Vector2.ZERO]
	var done: = {}  # Actually a set.
	
	while not queue.empty():
		var current: = get_min_dist_coords(dist, queue)
		queue.erase(current)
		done[current] = false  # Use it as set
		
		for rel in NEIGHBORS:
			var neighbor:Vector2 = current + rel
			if done.has(neighbor) or max(abs(neighbor.x), abs(neighbor.y)) > 10:
				continue
				
			if not check_free_way(current, neighbor):
				continue
				
			var new_dist:float = dist[current] + current.distance_to(neighbor)
			
			if not dist.has(neighbor):
				queue.append(neighbor)
			
			if new_dist < dist.get(neighbor, INFINITY):
				dist[neighbor] = new_dist
				parent[neighbor] = current
				
	if show_debug_path:
		update()
	
func _process(delta):
	for wall in tiles.values():
		wall.position = (wall.position + coords_to_pos(pos_to_coords(wall.position))) / 2

func _draw():
	if not show_debug_path:
		return
	for coords in parent.keys():
		var source: = coords_to_pos(coords)
		var target: = coords_to_pos(parent[coords])
		var middle: = (source + target) / 2
		draw_line(source, target, Color.white, false)
		draw_line(middle, middle + (source-target).normalized().rotated(0.5) * 3, Color.white, false)
		draw_line(middle, middle + (source-target).normalized().rotated(-0.5) * 3, Color.white, false)
