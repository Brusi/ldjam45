extends Node2D

const EXPLODE_RANGE = 10
const SHOT_RADIUS = 16

const WALL_COLORS = [Color("6d6b83"), Color("bebcd4"), Color("a3a1b7"), Color("807e96")]
const ENEMY_COLORS = [Color("352e5a"), Color("6e61b9"), Color("8176c2"), Color("9488de")]
const GEM_COLORS = [Color("711814"), Color("a52620"), Color("dc4635"), Color("e16455"), Color("f4cdc5")]

var shots: = []

var way_blocked: = false

var lost: = false

var coins_collected: = 0

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
		
	if Input.is_key_pressed(KEY_Q):
		$Env.add_wall(Env.pos_to_coords($Target.position))
		
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
			show_score()
			return true
			
	return false

func _physics_process(delta):
	if check_lose():
		return
	
	for enemy in get_enemies():
		if enemy.is_destroyed:
			continue
		for shot in shots:
			if (enemy.position - shot.position).length() < SHOT_RADIUS:
				enemy.destroy()
				shot.destroy()
				
				# Destroy other enemies which are near shot
				for enemy2 in get_enemies():
					if enemy2 == enemy:
						continue
					if enemy.position.distance_to(enemy2.position) < Env.SIZE:
						enemy2.destroy_no_wall()
				continue
				
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.is_destroyed:
			continue
		var coords:Vector2 = enemy.coords()
		if $Env.tiles.has(enemy.coords()):
			$Env.remove_wall(coords)
			enemy.destroy_no_wall()
			create_particles(Env.coords_to_pos(coords), WALL_COLORS, 100)
			
	for coin in get_coins():
		if coin.position.distance_to($Player.position) < Env.SIZE:
			coin_taken(coin)
			pause_effect(0.05)
			
func show_score():
	$UI/Control/ScoreView.visible = true
	$UI/Control/ScoreView/Score.text = "x "+String(coins_collected)
	$UI/Control/ScoreView/ScoreTimer.stop()
	

func coin_taken(coin):
	coins_collected += 1
	show_score()
	$UI/Control/ScoreView/ScoreTimer.start()
	# create_particles(coin.position, GEM_COLORS, 30)
	coin.queue_free()
	
func create_enemy(init_pos:Vector2, stationary:bool):
	var enemy:Enemy = preload("res://Enemy.tscn").instance()
	enemy.position = init_pos
	enemy.stationary = stationary
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
	for coin in get_coins():
		if Env.pos_to_coords(coin.position) == Env.pos_to_coords(enemy.position):
			create_particles(coin.position, GEM_COLORS, 30)
			coin.queue_free()
			
	enemy.queue_free()
			
	if check_circle():
		return
	
	$Camera.screen_shake()
	pause_effect()
	
	for e in get_tree().get_nodes_in_group("enemies"):
		if e == enemy or Env.pos_to_coords(e.position) == Env.pos_to_coords(enemy.position):
			continue
		e.calc_path()
	
func _on_Enemy_destroyed_no_wall(enemy):
	create_particles(enemy.position, ENEMY_COLORS, 100)
	enemy.queue_free()

func _on_Enemy_reached_center(enemy):
	check_lose()
	# enemy.queue_free()

func _on_Enemy_blocked(enemy):
	pass

func _on_Spawner_spawned(pos:Vector2, stationary:bool):
	if lost:
		return
	create_enemy(pos, stationary)

func pause_effect(wait_time: = 0.1):
	$PauseEffectTimer.start(wait_time)
	get_tree().paused = true
	
	
func create_particles(pos:Vector2, colors:Array, num:int):
	for i in range(num):
		create_particle(pos, Utils.rand_array(colors))

func create_particle(pos:Vector2, color:Color):
	var p:Particle = preload("res://Particle.tscn").instance()
	p.init(pos, color)
	add_child(p)

func _on_PauseEffectTimer_timeout():
	get_tree().paused = false

func _on_Exploder_done_expanding(expanded:Dictionary):
	for coords in expanded.keys():
		if $Env.has_wall(coords):
			create_coin(Env.coords_to_pos(coords))
			$Env.remove_wall(coords)
			create_particles(Env.coords_to_pos(coords), WALL_COLORS, 30)
			
	$Spawner.next_level()
	
	get_tree().paused = false
	
	for e in get_tree().get_nodes_in_group("enemies"):
		if Env.pos_to_coords(e.position).length() < EXPLODE_RANGE:
			create_coin(e.position)
			e.call_deferred("destroy_no_wall")
			continue
		
		e.stopped = false
		e.calc_path()
		
	$Camera.screen_shake(1)


func _on_ScoreTimer_timeout():
	$UI/Control/ScoreView.visible = false


func _on_Tutorial_set_label(text):
	set_label(text)


func _on_Tutorial_spawn_enemy(coords, stationary):
	create_enemy(Env.coords_to_pos(coords), stationary)
	pass # Replace with function body.
