extends Node

const fire = [preload("res://sound/fire.ogg")]
const hit = [preload("res://sound/hit.ogg")]
const stoned = [preload("res://sound/stoned_3.ogg")]
const gem = [preload("res://sound/gem.ogg")]
const circle = [preload("res://sound/circle.ogg")]
const death = [preload("res://sound/death.ogg")]
const breaking = [preload("res://sound/break_0.ogg"), preload("res://sound/break_1.ogg")]

var streams: = {}

var on: = true

# Called when the node enters the scene tree for the first time.
func _ready():
	create_stream(fire).volume_db = -6
	pause_mode = PAUSE_MODE_PROCESS
	pass # Replace with function body.
	
func _process(delta):
	if Input.is_action_just_pressed("toggle_sound"):
		on = not on
		
		if not on:
			for stream in streams.values():
				stream.stop()

func create_stream(arr:Array) -> AudioStreamPlayer: 
	var new_stream: = AudioStreamPlayer.new()
	add_child(new_stream)
	streams[arr] = new_stream
	return new_stream

func play_random_sound(arr:Array):
	if not on:
		return
	
	if not streams.has(arr):
		create_stream(arr)

	var stream = streams[arr]
	
	var rand_stream: = AudioStreamRandomPitch.new()
	rand_stream.random_pitch = 1.02
	rand_stream.audio_stream = Utils.rand_array(arr)
		
	stream.stream = rand_stream #Utils.rand_array(arr)
	stream.play()
