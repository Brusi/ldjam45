extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		get_tree().change_scene("res://Tutorial.tscn")

func _on_BlinkTimer_timeout():
	$Label.visible = not $Label.visible
