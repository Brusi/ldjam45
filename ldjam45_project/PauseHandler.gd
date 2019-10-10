extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	$"../UI/Control/PauseView".visible = $"..".paused
	
	if Input.is_action_just_pressed("pause"):
		$"..".paused = not $"..".paused
		get_tree().paused = $"..".paused
		
	if Input.is_action_just_pressed("restart"):
		get_tree().paused = false
		$"..".restart()
		
func _unhandled_input(event):
	if event is InputEventMouse and event.is_pressed() and event.button_index == BUTTON_LEFT:
		$"..".paused = false
		get_tree().paused = false
