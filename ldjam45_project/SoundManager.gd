extends Node

const fire = [preload("res://sound/fire.ogg")]
const hit = [preload("res://sound/hit.ogg")]

var streams: = {}

var on: = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if Input.is_action_just_pressed("toggle_sound"):
		on = not on
		
		if not on:
			for stream in streams.values():
				stream.stop()


func play_random_sound(arr:Array):
	if not on:
		return
	
	if not streams.has(arr):
		var new_stream = AudioStreamPlayer.new()
		add_child(new_stream)
		streams[arr] = new_stream
		
	var stream = streams[arr]
		
	stream.stream = Utils.rand_array(arr)
	stream.play()
