extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var sprite:Sprite = $"../Sprite"
	if Utils.bernoulli(0.9):
		sprite.texture = load("res://assets/wall_particles/wall_particle_"+String(randi()%7)+".png")
	else:
		sprite.texture = load("res://assets/wall_particles/wall_particle_"+String(randi()%2+7)+".png")
	sprite.rotation_degrees = randi()%4 * 90
