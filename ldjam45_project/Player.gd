extends Node2D

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
		
	if vel.length() != 0:
		vel = vel.normalized() * speed
		position += vel

func _process(delta):
	pass

func disable():
	enabled = false