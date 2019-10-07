extends Node2D

export var speed: = 0.5
export var diminish: = 4.0


var dir: = Utils.rand_dir() * speed

func _ready():
	pass # Replace with function body.

func _process(delta:float) -> void:
	pass
	position += dir
	$Sprite.scale.x -= delta*diminish
	$Sprite.scale.y -= delta*diminish
	if $Sprite.scale.x <= 0:
		queue_free()