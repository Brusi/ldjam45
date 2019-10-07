extends Node2D

export var on_top_offset: = -10000.0

export var size: = 15
export var large_chance: = 0.02#0.3
export var empty_chance: = 0.8#0.4

var used: = {}

func _ready():
	position.y = on_top_offset
	for i in range(-size, size+1):
		for j in range(-size, size+1):
			if is_used(i,j):
				continue
				
			set_used(i,j)
				
			if not is_used(i+1,j) and not is_used(i,j+1) and not is_used(i+1,j+1) and Utils.bernoulli(large_chance):
				var tile = preload("res://FloorBig.tscn").instance()
				tile.position = Env.coords_to_pos(Vector2(i,j)) + Vector2(0, -on_top_offset)
				add_child(tile)
				
				set_used(i+1,j)
				set_used(i,j+1)
				set_used(i+1,j+1)
				continue
				
			if not Utils.bernoulli(empty_chance):
				var tile = preload("res://FloorSmall.tscn").instance()
				tile.position = Env.coords_to_pos(Vector2(i,j)) + Vector2(0, -on_top_offset)
				add_child(tile)
			
	
func set_used(i:int, j:int) -> void:
	used[Vector2(i,j)] = false
	
func is_used(i:int, j:int) -> bool:
	if i > size or j > size:
		return true
	return used.has(Vector2(i,j))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
