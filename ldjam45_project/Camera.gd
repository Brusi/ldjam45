extends Camera2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player
var target

var screenshake_on: = false

var enable_focus: = false
var focus: = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	player = $"../Player"
	target = $"../Target"

func _process(delta):
	if enable_focus:
		position = focus
	else:
		position = (player.position * 5 + target.position) / 6
	
	if screenshake_on:
		offset = Utils.rand_dir() * 1
		
	position.x = round(position.x)
	position.y = round(position.y)
	
func screen_shake(time:= 0.2):
	if $ScreenShakeTimer.time_left >= time:
		return
	$ScreenShakeTimer.start(time)
	screenshake_on = true

func focus_on(f:Vector2):
	focus = f
	enable_focus = true

func _on_ScreenShakeTimer_timeout():
	screenshake_on = false
	offset = Vector2.ZERO
