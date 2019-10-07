extends Node2D

const SPEED: = 0.5

var dir: = Utils.rand_dir() * SPEED

func _ready():
	pass # Replace with function body.

func _process(delta:float) -> void:
	pass
	position += dir
	$Sprite.scale.x -= delta*4
	$Sprite.scale.y -= delta*4
	if $Sprite.scale.x <= 0:
		queue_free()
	


