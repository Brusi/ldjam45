extends Node2D

class_name Enemy

signal destroyed(enemy)
signal destroyed_no_wall(enemy)
signal reached_center(enemy)
signal blocked(enemy)

export var type: = 1

export var speed: = 0.5
export var stationary: = false

export var hp: = 1

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
	if stationary or stopped:
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
	if stationary or stopped or calculating:
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
	
func hit() -> void:
	hp -= 1
	if hp == 0:
		destroy()
	modulate = Color.black
	$RecolorTimer.start()

func destroy():
	if is_destroyed:
		return
	is_destroyed = true
	emit_signal("destroyed", self)
	
func destroy_no_wall():
	if is_destroyed:
		return
	is_destroyed = true
	emit_signal("destroyed_no_wall", self)
	
func _process(delta:float):
	if stationary or stopped or calculating:
		$Back.visible = false
		$Front.visible = false
		$Idle.visible = true
		return
	
	if vel.y > 0:
		$Back.visible = false
		$Front.visible = true
	else:
		$Front.visible = false
		$Back.visible = true

func _on_RecolorTimer_timeout():
	modulate = Color.white
