extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	pass
	
func _process(delta):
	modulate.a = min(modulate.a + delta * 2, 1)


