extends Node2D

class_name Enemy

signal destroyed(enemy)
signal destroyed_no_wall(enemy)
signal reached_center(enemy)
signal blocked(enemy)

export var speed: = 1

var path: = []

var target: = Vector2()

var vel: = Vector2()

var calculating: = false
var stopped: = false
var aggressive_mode: = false
var is_destroyed: = false

# Called when the node enters the scene tree for the first time.
func _ready():
	calc_path()
	
func stop() -> void:
	stopped = true
	
func calc_path() -> void:
	if stopped:
		return
		
	calculating = true
	
	path = $"../Env".astar(coords())
	# print("path=",path)
	calculating = false
	# stopped = path.empty()
	if not path.empty():
		aggressive_mode = false
	else:
		print("path too complicated, falling back to aggressive mode")
		aggressive_mode = true

func _physics_process(delta):
	if stopped or calculating:
		return
		
	if aggressive_mode:
		target = Vector2.ZERO
	elif path != null and not path.empty():
		if path[0] == coords():
			path.pop_front()
			if not path.empty():
				target = Env.coords_to_pos(path.front())
			else:
				target = Vector2.ZERO
			
	vel = (target - position).normalized() * speed
	
	position += vel
	
	if coords() == Vector2.ZERO:
		emit_signal("reached_center", self)
		
	
func coords() -> Vector2:
	return Env.pos_to_coords(position)
	
func destroy():
	is_destroyed = true
	emit_signal("destroyed", self)
	
func destroy_no_wall():
	emit_signal("destroyed_no_wall", self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
