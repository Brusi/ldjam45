extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta:float):
	# var pos:Vector2 = get_viewport().get_gloabl_mouse_pos() + $"../Player".position - get_viewport().size / 2
	position = get_global_mouse_position()

#func _process(delta):
#	pass
