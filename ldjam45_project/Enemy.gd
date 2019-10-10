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

var target: = Vector2()

var vel: = Vector2()

var stopped: = false
var is_destroyed: = false

var thread:Thread

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func stop() -> void:
	stopped = true
	
func _physics_process(delta):
	if stationary or stopped:
		return
	
	target = Env.coords_to_pos($"../Env".parent[coords()] if $"../Env".parent.has(coords()) else Vector2(0,0))
	
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
		SoundManager.play_random_sound(SoundManager.stoned)
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
	if stationary or stopped:
		$Back.visible = false
		$Front.visible = false
		$Idle.visible = true
		return
		
	if vel.y > 0:
		$Back.visible = false
		$Front.visible = true
		$Idle.visible = false
	else:
		$Front.visible = false
		$Back.visible = true
		$Idle.visible = false

func _on_RecolorTimer_timeout():
	modulate = Color.white
