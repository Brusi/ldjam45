extends Node

signal set_label(text)
signal spawn_enemy(coords, stationary)

enum State {
	START,
	MOVED,
	CREATED_ONE,
	CREATED_MANY,
	COMPLETED_CIRCLE,
	COLLECTED_GEMS,
	DONE
}

var state:int = State.START

func is_done():
	return state == State.DONE

func _ready():
	emit_signal("set_label", "WASD to move")

func _process(delta:float):
	match state:
		State.START:
			if $"../Player".position.length() > Env.SIZE:
				state = State.MOVED
		State.MOVED:
			emit_signal("set_label", "Shoot Gargoyles with mouse")
			emit_signal("spawn_enemy", Vector2(3, 0), true)
			state = State.CREATED_ONE
		State.CREATED_ONE:
			if $"..".get_enemies().empty():
				$"../Player".position = Vector2.ZERO
				emit_signal("set_label", "Complete the circle")
				
				emit_signal("spawn_enemy", Vector2(-3, 0), true)
				for x in [1, -1]:
					emit_signal("spawn_enemy", Vector2(0, 3 * x), true)
					for y in [1, -1]:
						emit_signal("spawn_enemy", Vector2(3 * y, 1 * x), true)
						emit_signal("spawn_enemy", Vector2(1 * y, 3 * x), true)
						emit_signal("spawn_enemy", Vector2(2 * y, 2 * x), true)
				state = State.CREATED_MANY
		State.CREATED_MANY:
			if $"..".get_enemies().empty():
				state = State.COMPLETED_CIRCLE
				emit_signal("set_label", "Collect gems")
		State.COMPLETED_CIRCLE:
			if $"..".get_coins().empty():
				state = State.COLLECTED_GEMS
				emit_signal("set_label", "Protect the orb!")
				for i in range(4):
					var dir = Utils.rand_dir()
					emit_signal("spawn_enemy", dir * (10 + i*6), false)
					emit_signal("spawn_enemy", dir * (11.5 + i*6), false)
					emit_signal("spawn_enemy", dir * (13 + i*6), false)
					
				
		State.COLLECTED_GEMS:
			if $"..".get_enemies().empty():
				emit_signal("set_label", "Well done! Get ready...")
				state = State.DONE
				$TutorialDoneTimer.start()
				
		State.DONE:
			pass

func _on_TutorialDoneTimer_timeout():
	get_tree().change_scene("res://Game.tscn")

