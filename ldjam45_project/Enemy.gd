extends Node2D

class_name Enemy

signal destroyed(enemy)
signal destroyed_no_wall(enemy)
signal reached_center(enemy)
signal blocked(enemy)

export var type: = 1

export var speed: = 0.5
export var stationary: = false
export var skipper: = false

export var hp: = 1

var path: = []

var prev_target: = Vector2()
var target: = Vector2()

var vel: = Vector2()

var calculating: = false
var stopped: = false
var aggressive_mode: = false
var is_destroyed: = false

var skip_free_way: = true

# Called when the node enters the scene tree for the first time.
func _ready():
	calc_path()
	
func stop() -> void:
	stopped = true
	
func calc_path() -> void:
	if stationary or stopped:
		return
		
	calculating = true
	
	path = $"../Env".astar(coords(), Vector2.ZERO, skipper)
	
	if skipper:
		if path.size() >= 2:
			target = Env.coords_to_pos(path[1])
			skip_free_way = true
		else:
			target = Env.coords_to_pos(path[0])
			skip_free_way = true
	
	# print("path=",path)
	calculating = false
	# stopped = path.empty()
	if not path.empty():
		aggressive_mode = false
	else:
		# print("path too complicated, falling back to aggressive mode")
		aggressive_mode = true

func _physics_process(delta):
	if stationary or stopped or calculating:
		return
		
	if aggressive_mode:
		target = Vector2.ZERO
	elif path != null and not path.empty():
		if (not skipper and path[0] == coords()) or position == target:
			path.pop_front()
			if not path.empty():
				var next_target: = Env.coords_to_pos(path.front())
				if next_target != target:
					prev_target = target
					target = next_target
				skip_free_way = $"../Env".check_free_way(Env.pos_to_coords(prev_target), Env.pos_to_coords(next_target))
			else:
				target = Vector2.ZERO
			
	var diff: = target - position
	if diff.length() < speed:
		position = target
	else:
		vel = diff.normalized() * speed
		position += vel
	
	if coords() == Vector2.ZERO:
		emit_signal("reached_center", self)
		
	
func coords() -> Vector2:
	return Env.pos_to_coords(position)
	
func hit() -> void:
	hp -= 1
	if hp == 0:
		destroy()
	else:
		SoundManager.play_random_sound(SoundManager.hit)
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
	
func near_wall() -> bool:
	var env = $"../Env"
	for x in [-1, 0, 1]:
		for y in [-1, 0, 1]:
			if env.has_wall(coords() + Vector2(x,y)):
				return true
	return false
	
func _process(delta:float):
	if stationary or stopped or calculating:
		$Back.visible = false
		$Front.visible = false
		$Idle.visible = true
		return
		
	if skipper:
		var skip_length: = target.distance_to(prev_target)
		var z: = 0.0
		if skip_length != 0:
			var t:float = target.distance_to(position) / skip_length
			print("target=", target)
			print("prev_t=", prev_target)
			print("position=", position)
			#print("t=",t)
			z = -t*(1-t)*50 * (3 if near_wall() else 1)

		$Back.position.y = ($Back.position.y*2  + z) / 3
		$Front.position.y =	($Back.position.y*2  + z) / 3
	
	if vel.y > 0:
		$Back.visible = false
		$Front.visible = true
	else:
		$Front.visible = false
		$Back.visible = true

func _on_RecolorTimer_timeout():
	modulate = Color.white
