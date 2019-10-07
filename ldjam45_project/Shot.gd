extends Node2D

signal destroyed(shot)

export var speed: = 6

var vel: = Vector2()

var init_pos:Vector2

func init(_init_pos:Vector2, _target_pos:Vector2):
	init_pos = _init_pos
	var dir: = (_target_pos - _init_pos).normalized()
	vel = dir * speed
	
	position = init_pos + dir * 10 + Vector2(0, 3)
	
func _physics_process(delta):
	position += vel
	if (position - init_pos).length() > 80:
		emit_signal("destroyed", self)
		
func destroy():
	emit_signal("destroyed", self)
