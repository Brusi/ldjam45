extends Node

signal spawned(pos, stationary)
signal new_wave

export var enabled: = true

export var num_enemies: = 3
export var max_num_enemies: = 6

export var chance_scatter: = 0.5

var active: = true

func _ready():
	active = enabled
	pass # Replace with function body.
	
func spawn_enemies(dir:Vector2, i):
	if i == num_enemies:
		return
	var actual_dir = dir if dir != Vector2.ZERO else Utils.rand_dir()
		
	emit_signal("spawned", actual_dir * (250 + i * 40), false)
	call_deferred("spawn_enemies", dir, i+1)

func _on_Timer_timeout():
	if not active:
		return
	
	var dir := Vector2.ZERO
	if not Utils.bernoulli(chance_scatter):
		dir = Utils.rand_dir()
			
	call_deferred("spawn_enemies", dir, 0)

func stop() -> void:
	active = false
	
func no_enemies() -> void:
	pass
	
func next_level() -> void:
	if not enabled:
		return
	num_enemies = min(max_num_enemies, num_enemies+1)