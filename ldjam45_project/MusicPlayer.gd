extends Node

const GAME_MUSIC: = preload("res://assets/music.ogg")

var current_music = null
var on: = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	var stream = AudioStreamPlayer.new()
	stream.name = "Stream"
	add_child(stream)
	
	play_game_music()
	
func _process(delta):
	if Input.is_action_just_pressed("toggle_music"):
		on = not on
		
		if on:
			_play_current()
		else:
			$Stream.stop()
	
func _play_current():
	if $Stream.is_playing():
		return
	$Stream.stream = current_music
	$Stream.volume_db = -5
	$Stream.play()
	
func play_game_music():
	if current_music == GAME_MUSIC:
		return
		
	current_music = GAME_MUSIC
	if not on:
		return
		
	_play_current()
	
func stop_game_music():
	if current_music == GAME_MUSIC:
		$Stream.stop()
	