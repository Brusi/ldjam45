extends Node2D

const BOUNDS: = Env.SIZE * 3 / 8

export var speed: = 2;

var vel: = Vector2()
var look_right: = true

var enabled: = true

var env:Env

var walk_offset: = 0

static func player_input(action:String) -> bool:
	return Input.is_action_pressed(action)

# Called when the node enters the scene tree for the first time.
func _ready():
	recenter()

func recenter():
	position = Env.coords_to_pos(Vector2(-1, 0))
	
func _physics_process(delta):
	if not enabled:
		vel = Vector2.ZERO
		return
		
	for corner in get_corners(position):
		var corner_coords: = Env.pos_to_coords(corner)
		if $"../Env".has_wall(corner_coords):
			position += Utils.rand_dir()
	
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
			var corner_coords: = Env.pos_to_coords(corner)
			if $"../Env".has_wall(corner_coords):
				blocked = true
				break
		if not blocked:
			position += advancement


func _process(delta):
	if not enabled:
		return
	var dir: = get_global_mouse_position() - position
	
	var looking_right = dir.x >= 0
	$Main.scale.x = 1.0 if looking_right else -1.0
	$Staff.position.x = 2 if looking_right else -2
	$Staff.rotation = dir.angle()
		
	if vel.length() > 0:
		$Main.position.y = -walk_offset

func disable():
	enabled = false
	
func get_corners(source:Vector2) -> Array:
	var corners: = []
	for x in [-1, 1]:
		for y in [-1, 1]:
			corners.append(source + Vector2(x * BOUNDS, y * BOUNDS))
			
	return corners

func _on_WalkTimer_timeout():
	walk_offset = 1 - walk_offset
	pass # Replace with function body.
