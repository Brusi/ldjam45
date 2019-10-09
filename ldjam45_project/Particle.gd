extends Node2D

class_name Particle

const GRAVITY = 300

const RED = 240.0 / 256.0

var vel: = Vector2()
var vel_z: = 0.0
var z: = 0.0

export var shrink: = true

var IDLE_TIME: = 4.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite.position.y = -z + 0
	pass # Replace with function body.
	
func init(init_pos:Vector2, color:Color = Color.white):
	position = init_pos + Utils.rand_dir() * rand_range(2,6)
	position.y -= 0
	vel = Utils.rand_dir() * rand_range(10, 40)
	vel.y /= 2
	vel_z = rand_range(40, 100)
	
	modulate = color
	
	
func _process(delta):
	vel_z -= GRAVITY * delta
	z += vel_z * delta
	
	if z < 0:
		z = 0
		vel_z = -vel_z * 0.5
		vel =  vel * 0.5
	
	position += vel * delta
	$Sprite.position.y = -z + 0
	
	if shrink and vel.length() < 0.1:
		scale.x = max(0.0,scale.x - delta/IDLE_TIME)
		scale.y = scale.x
		if scale.x <= 0.001:
			queue_free()
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
