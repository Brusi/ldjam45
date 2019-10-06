extends Node

signal spawned(pos, moving)
signal new_wave

export var num_enemies: = 4

var active: = true

func _ready():
	pass # Replace with function body.
	
func spawn_enemies(dir:Vector2, i):
	if i == num_enemies:
		return
	emit_signal("spawned", dir * (250 + i * 40), true)
	call_deferred("spawn_enemies", dir, i+1)

func _on_Timer_timeout():
	var dir: = Utils.rand_dir()
	call_deferred("spawn_enemies", dir, 0)

func stop() -> void:
	active = false
	
func no_enemies() -> void:
	pass