extends Node2D

class_name Coin

signal timed_out

const GRAVITY = 300

const RED = 240.0 / 256.0

var vel: = Vector2()
var vel_z: = 0.0
var z: = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	vel_z = rand_range(100, 150)
	pass # Replace with function body.

func _process(delta):
	vel_z -= GRAVITY * delta
	z += vel_z * delta
	
	if z < 0:
		z = 0
		vel_z = -vel_z * 0.5
		vel =  vel * 0.5
	
	position += vel * delta
	$Sprite.position.y = -z

func _on_TimeoutTimer_timeout():
	queue_free()

func _on_StartBlinkTimer_timeout():
	$BlinkTimer.start()

func _on_BlinkTimer_timeout():
	$Sprite.visible = not $Sprite.visible
