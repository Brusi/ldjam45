extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var sprite:Sprite = $"../Sprite"
	sprite.texture = load("res://assets/orb_particles/orb_particle_"+String(randi()%6)+".png")
	sprite.rotation_degrees = randi()%4 * 90

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
