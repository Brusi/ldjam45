extends Node2D

var type: = 0 setget set_type

func _ready():
	$AnimatedSprite.play("default")
	pass # Replace with function body.
	
func set_type(value:int):
	type = value
	match type:
		0:
			$Normal.visible = true
			$Big.visible = false
			$Thin.visible = false
		1:
			$Normal.visible = false
			$Big.visible = true
			$Thin.visible = false
		2:
			$Normal.visible = false
			$Big.visible = false
			$Thin.visible = true


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.visible = false
