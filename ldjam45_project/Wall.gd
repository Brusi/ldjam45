extends Node2D

var type: = 0 setget set_type

func _ready():
	pass # Replace with function body.
	
func set_type(value:int):
	type = value
	if type == 0:
		$Normal.visible = true
		$Big.visible = false
	else:
		$Normal.visible = false
		$Big.visible = true
