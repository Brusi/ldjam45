extends Node2D

signal destroyed(shot)

export var speed: = 6

var vel: = Vector2()

var init_pos:Vector2

func init(_init_pos:Vector2, _target_pos:Vector2):
	init_pos = _init_pos
	position = init_pos
	vel = (_target_pos - _init_pos).normalized() * speed
	
func _physics_process(delta):
	position += vel
	if (position - init_pos).length() > 150:
		emit_signal("destroyed", self)
		
func destroy():
	emit_signal("destroyed", self)
