extends Node2D

const EXPLODE_RANGE = 20
const SHOT_RADIUS = 16

var shots: = []

var way_blocked: = false

var lost: = false

func set_label(text:String) -> void:
	$UI/Control/Label.text = text

func get_coins() -> Array:
	return get_tree().get_nodes_in_group("coins")
	
func get_enemies() -> Array:
	return get_tree().get_nodes_in_group("enemies")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	$Player.env = $Env

func _process(event):
	if not lost and Input.is_mouse_button_pressed(BUTTON_LEFT):
		if $ShotsTimer.time_left <= 0:
			$ShotsTimer.start()
			var shot = preload("res://Shot.tscn").instance()
			shot.init($Player.position, $Target.position)
			shot.connect("destroyed", self, "_on_Shot_destroyed")
			shots.append(shot)
			add_child(shot)
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		
	if get_enemies().empty():
		$Spawner.no_enemies()

func check_lose() -> bool:
	if lost:
		return true
	
	for enemy in get_enemies():
		if enemy.coords() == Vector2.ZERO or enemy.position.distance_to($Player.position) < Env.SIZE:
			$Camera.focus_on(enemy.position)
			for enemy in get_enemies():
				enemy.stop()
			lost = true
			$Camera.screen_shake(3)
			$Player.disable()
			set_label("You lost! Hit R to restart.")
			return true
			
	return false

func _physics_process(delta):
	if check_lose():
		return
	
	for enemy in get_enemies():
		for shot in shots:
			if (enemy.position - shot.position).length() < SHOT_RADIUS:
				enemy.destroy()
				shot.destroy()
				
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.is_destroyed:
			continue
		var coords:Vector2 = enemy.coords()
		if $Env.tiles.has(enemy.coords()):
			$Env.remove_wall(coords)
			enemy.destroy_no_wall()
			
	for coin in get_coins():
		if coin.position.distance_to($Player.position) < Env.SIZE:
			coin_taken(coin)
			pause_effect(0.05)
			

func coin_taken(coin):
	coin.queue_free()
	
func create_enemy(init_pos:Vector2, moving:bool):
	var enemy:Enemy = preload("res://Enemy.tscn").instance()
	enemy.position = init_pos
	enemy.connect("destroyed", self, "_on_Enemy_destroyed")
	enemy.connect("destroyed_no_wall", self, "_on_Enemy_destroyed_no_wall")
	enemy.connect("reached_center", self, "_on_Enemy_reached_center")
	enemy.connect("blocked", self, "_on_Enemy_blocked")
	add_child(enemy)
	
func create_coin(init_pos:Vector2):
	var coin = preload("res://Coin.tscn").instance()
	coin.position = init_pos
	coin.connect("timed_out", self, "_on_Coin_timed_out")
	add_child(coin)

func _on_Shot_destroyed(shot:Node2D) -> void:
	shots.erase(shot)
	shot.queue_free()
	
func check_circle():
	var min_coords = $Env.get_min_coords()
	var max_coords = $Env.get_max_coords()
	# Check if we can get the center from outsde the box.
	if $Env.get_first_reachable_corner().empty():
		print("no reachable corners")
		get_tree().paused = true
		$Exploder.start()
		$PauseEffectTimer.stop()
			
		return true
	
	return false
	
func _on_Enemy_destroyed(enemy):
	$Env.add_wall_at(enemy.position)
	_on_Enemy_destroyed_no_wall(enemy)

func _on_Enemy_destroyed_no_wall(enemy):
	enemy.queue_free()
	
	if check_circle():
		return
	
	$Camera.screen_shake()
	pause_effect()
	
	
	for e in get_tree().get_nodes_in_group("enemies"):
		if e == enemy or Env.pos_to_coords(e.position) == Env.pos_to_coords(enemy.position):
			continue
		e.calc_path()
		
func _on_Enemy_reached_center(enemy):
	check_lose()
	# enemy.queue_free()

func _on_Enemy_blocked(enemy):
	pass

func _on_Spawner_spawned(pos:Vector2, moving:bool):
	if lost:
		return
	create_enemy(pos, moving)

func pause_effect(wait_time: = 0.1):
	$PauseEffectTimer.start(wait_time)
	get_tree().paused = true

func _on_PauseEffectTimer_timeout():
	get_tree().paused = false

func _on_Exploder_done_expanding(expanded:Dictionary):
	for coords in expanded.keys():
		if expanded[coords]:
			create_coin(Env.coords_to_pos(coords))
			$Env.remove_wall(coords)
	
	get_tree().paused = false
	
	for e in get_tree().get_nodes_in_group("enemies"):
		if Env.pos_to_coords(e.position).length() < EXPLODE_RANGE:
			create_coin(e.position)
			e.call_deferred("destroy_no_wall")
			continue
		
		e.stopped = false
		e.calc_path()
		
	$Camera.screen_shake(1)
