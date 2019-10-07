extends Node

signal set_label(text)
signal spawn_enemy(coords, stationary)
signal done

enum State {
	START,
	MOVED,
	CREATED_ONE,
	CREATED_MANY,
	COMPLETED_CIRCLE,
	AFTER_BLAST,
	COLLECTED_GEMS,
	DONE
}

var state:int = State.START

func is_done():
	return state == State.DONE

func _ready():
	emit_signal("set_label", "[WASD] to move")

func _process(delta:float):
	match state:
		State.START:
			if $"../Player".position.length() > Env.SIZE:
				state = State.MOVED
		State.MOVED:
			emit_signal("set_label", "Shoot Gargoyles")
			emit_signal("spawn_enemy", Vector2(3, 0), true)
			state = State.CREATED_ONE
		State.CREATED_ONE:
			if $"..".get_enemies().empty():
				$"../Player".recenter()
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
				emit_signal("set_label", "Collect gems")
				state = State.COMPLETED_CIRCLE
				$BlastTimer.start(2)
		State.COMPLETED_CIRCLE:
			pass
		State.AFTER_BLAST:
			if $"..".get_coins().empty():
				state = State.COLLECTED_GEMS
				emit_signal("set_label", "Protect The Orb!")
				emit_signal("done")
				$TutorialDoneTimer.start()
				state = State.COLLECTED_GEMS
				
		State.COLLECTED_GEMS:
			pass
				
		State.DONE:
			pass

func _on_TutorialDoneTimer_timeout():
	emit_signal("set_label", "")
	state = State.DONE

func _on_BlastTimer_timeout():
	state = State.AFTER_BLAST
