extends Node2D

const BOUNDS: = Env.SIZE * 3 / 8

export var speed: = 2;

var vel: = Vector2()
var look_right: = true

var enabled: = true

var env:Env

static func player_input(action:String) -> bool:
	return Input.is_action_pressed(action)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	if not enabled:
		return
	
	if player_input("ui_right"):
		vel.x = 1
		look_right = true
	elif player_input("ui_left"):
		vel.x = -1
		look_right = false
	else:
		vel.x = 0
		
	if player_input("ui_down"):
		vel.y = 1
	elif player_input("ui_up"):
		vel.y = -1
	else:
		vel.y = 0
		
	if vel.length() == 0:
		return
	
	vel = vel.normalized() * speed
	
	for advancement in [Vector2(vel.x, 0), Vector2(0, vel.y)]:
		var blocked: = false
		for corner in get_corners(position + advancement):
			if $"../Env".has_wall(Env.pos_to_coords(corner)):
				blocked = true
				break
		if not blocked:
			position += advancement

func _process(delta):
	pass

func disable():
	enabled = false
	
func get_corners(source:Vector2) -> Array:
	var corners: = []
	for x in [-1, 1]:
		for y in [-1, 1]:
			corners.append(source + Vector2(x * BOUNDS, y * BOUNDS))
			
	return corners