extends Sprite

var state_time: = 0.0

func _ready():
	pass # Replace with function body.

func _process(delta):
	state_time += delta
	offset.y = -15.0 - 2.0 * sin(state_time)
	var tint: = 0.9 + 0.05 * sin(state_time*4)
	modulate =  Color(tint, tint, tint) 
