extends Node2D

const EXPLODE_RANGE = 10
const SHOT_RADIUS = 16

# const WALL_COLORS = [Color("6d6b83"), Color("bebcd4"), Color("a3a1b7"), Color("807e96")]
const ENEMY_COLORS = [Color("352e5a"), Color("6e61b9"), Color("8176c2"), Color("9488de")]
const FAT_ENEMY_COLORS = [Color("1b3c39"), Color("439177"), Color("5cac84"), Color("72bd98")]
const GEM_COLORS = [Color("711814"), Color("a52620"), Color("dc4635"), Color("e16455"), Color("f4cdc5")]
const SHOT_COLORS = [Color("ffba59"), Color("ffe675"), Color("fff385"), Color("ffffe2")]

var shots: = []

var way_blocked: = false

var lost: = false

var coins_collected: = 0

var paused: = false

func set_label(text:String) -> void:
	$UI/Control/HintRect.visible = not text.empty()
	$UI/Control/Label.text = text

func get_coins() -> Array:
	return get_tree().get_nodes_in_group("coins")
	
func get_enemies() -> Array:
	return get_tree().get_nodes_in_group("enemies")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	$Player.env = $Env
	MusicPlayer._play_current()

func _process(event):
	check_circle()
	
	if not lost and Input.is_mouse_button_pressed(BUTTON_LEFT):
		if $ShotsTimer.time_left <= 0:
			$ShotsTimer.start()
			var shot = preload("res://Shot.tscn").instance()
			shot.init($Player.position, $Target.position)
			shot.connect("destroyed", self, "_on_Shot_destroyed")
			shots.append(shot)
			add_child(shot)
			SoundManager.play_random_sound(SoundManager.fire)
	
	if Input.is_key_pressed(KEY_COMMA):
		$Env.add_wall_at($Target.position)
	
	elif Input.is_key_pressed(KEY_PERIOD):
		var should_create: = true
		for enemy in get_enemies():
			if $Target.position.distance_to(enemy.position) < Env.SIZE:
				should_create = false
		if should_create:
			create_enemy($Target.position, false, 0)
		
	if get_enemies().empty():
		$Spawner.no_enemies()

func restart():
	var tut_node: = get_node_or_null("Tutorial")
	if tut_node != null and tut_node.is_done():
		get_tree().change_scene("res://Game.tscn")
	else :
		get_tree().reload_current_scene()

func check_lose() -> bool:
	if lost:
		return true
	
	for enemy in get_enemies():
		if enemy.coords() == Vector2.ZERO or enemy.position.distance_to($Player.position) < Env.SIZE:
			$Camera.focus_on(enemy.position)
			for enemy in get_enemies():
				enemy.stop()
			lost = true
			MusicPlayer.stop_game_music()
			SoundManager.play_random_sound(SoundManager.death)
			$Camera.screen_shake(3)
			$Player.disable()
			# set_label("You lost! [R] to restart.")
			$DeathTimer.start()
			
			for i in range(10):
				var p:Particle = preload("res://OrbParticle.tscn").instance()
				p.init(Vector2(0, 0))
				p.z = 15
				$Orb.visible = false
				add_child(p)
			
			return true
			
	return false
	
func create_shot_particle(pos:Vector2):
	var shot_particle:Node2D = preload("res://ShotParticle.tscn").instance()
	shot_particle.position = pos
	add_child(shot_particle)
	
func create_gem_particles(coin):
	for i in range(4):
		var particle:Node2D = preload("res://GemParticle.tscn").instance()
		particle.position = coin.position
		particle.get_node("Sprite").position.y = -coin.z
		particle.modulate = Utils.rand_array(GEM_COLORS)
		add_child(particle)

func _physics_process(delta):
	if check_lose():
		return
		
	for shot in shots:
		if Utils.bernoulli(0.5):
			create_shot_particle(shot.position)
			
		if $Env.has_wall_at(shot.position):
			var wall = $Env.get_wall_at(shot.position)
			if wall != null:
				wall.position += shot.vel * 1
			shot.destroy()
			SoundManager.play_random_sound(SoundManager.hit)
			continue
	
	for enemy in get_enemies():
		if enemy.is_destroyed:
			continue
		for shot in shots:
			if (enemy.position - shot.position).length() < SHOT_RADIUS:
				enemy.hit()
				pause_effect()
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
			$Env.dijkstra()
			enemy.destroy_no_wall()
			create_wall_particles(Env.coords_to_pos(coords))
			
			
	for coin in get_coins():
		if coin.position.distance_to($Player.position) < Env.SIZE * 2:
			coin.position += ($Player.position - coin.position) / 10
		if coin.position.distance_to($Player.position) < Env.SIZE:
			coin_taken(coin)
			pause_effect(0.02)
			
func show_score():
	$UI/Control/ScoreView.visible = true
	$UI/Control/ScoreView/Score.text = "x "+String(coins_collected)
	$UI/Control/ScoreView/ScoreTimer.stop()
	
func hide_score():
	$UI/Control/ScoreView.visible = false
	

func coin_taken(coin):
	SoundManager.play_random_sound(SoundManager.gem)
	coins_collected += 1
	show_score()
	$UI/Control/ScoreView/ScoreTimer.start()
	# create_particles(coin.position, GEM_COLORS, 30)
	create_gem_particles(coin)
	coin.queue_free()
	
func create_enemy(init_pos:Vector2, stationary:bool, type: = 0):
	
	var enemy_type_scene:PackedScene = preload("res://Enemy.tscn")
	match type:
		0: enemy_type_scene = preload("res://Enemy.tscn")
		1: enemy_type_scene = preload("res://FatEnemy.tscn")
		2: enemy_type_scene = preload("res://ThinEnemy.tscn")

	# enemy_type_scene = preload("res://ThinEnemy.tscn")
	var enemy:Enemy = (enemy_type_scene).instance()
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
	for i in range(10):
		create_shot_particle(shot.position)
	shot.queue_free()
	
func check_circle():
	$Exploder.start()
	return
	
	var min_coords = $Env.get_min_coords()
	var max_coords = $Env.get_max_coords()
	# Check if we can get the center from outsde the box.
	if $Env.get_first_reachable_corner().empty():
		get_tree().paused = true
		$Exploder.start()
		$PauseEffectTimer.stop()
			
		return true
	
	return false
	
func _on_Enemy_destroyed(enemy):
	var coords = Env.pos_to_coords(enemy.position)
	var wall = $Env.add_wall_at(enemy.position)
	if wall != null:
		wall.type = enemy.type
	else:
		create_wall_particles(enemy.position)
	
	for coin in get_coins():
		if Env.pos_to_coords(coin.position) == coords:
			create_gem_particles(coin)
			coin.queue_free()
			
	enemy.queue_free()
			
	$Camera.screen_shake()
	pause_effect()

func _on_Enemy_destroyed_no_wall(enemy):
	#var colors: = ENEMY_COLORS if enemy.type == 0 else FAT_ENEMY_COLORS
	#create_particles(enemy.position, colors, 100)
	create_wall_particles(enemy.position)
	enemy.queue_free()

func _on_Enemy_reached_center(enemy):
	check_lose()
	# enemy.queue_free()

func _on_Enemy_blocked(enemy):
	pass

func _on_Spawner_spawned(pos:Vector2, stationary:bool, type:int):
	if lost:
		return
	create_enemy(pos, stationary, type)

func pause_effect(wait_time: = 0.05):
	$PauseEffectTimer.start(wait_time)
	get_tree().paused = true
	
	
func create_particles(pos:Vector2, colors:Array, num:int):
	for i in range(num):
		create_particle(pos, Utils.rand_array(colors))

func create_particle(pos:Vector2, color:Color):
	var p:Particle = preload("res://Particle.tscn").instance()
	p.init(pos, color)
	add_child(p)

func create_wall_particles(pos:Vector2):
	for i in range(20):
		var p:Particle = preload("res://WallParticle.tscn").instance()
		p.init(pos)
		add_child(p)
	SoundManager.play_random_sound(SoundManager.breaking)

func _on_PauseEffectTimer_timeout():
	get_tree().paused = paused

func _on_Exploder_done_expanding(expanded:Dictionary):
	for e in get_tree().get_nodes_in_group("enemies"):
		#if Env.pos_to_coords(e.position).length() < EXPLODE_RANGE:
		# create_coin(e.position)
		e.destroy_no_wall()
		continue
	
	for coords in expanded.keys():
		if $Env.has_wall(coords):
			create_coin(Env.coords_to_pos(coords))
			$Env.remove_wall(coords)
			
			create_wall_particles(Env.coords_to_pos(coords))
			
	$Env.dijkstra()
	$Spawner.next_level()
	SoundManager.play_random_sound(SoundManager.breaking)
	
	get_tree().paused = paused
		
	$Camera.screen_shake(1)


func _on_ScoreTimer_timeout():
	$UI/Control/ScoreView.visible = false


func _on_Tutorial_set_label(text):
	set_label(text)


func _on_Tutorial_spawn_enemy(coords:Vector2, stationary:bool):
	create_enemy(Env.coords_to_pos(coords), stationary)
	pass # Replace with function body.


func _on_Tutorial_done():
	print("_on_Tutorial_done")
	$Spawner.enabled = true
	$Spawner.start()
	coins_collected = 0
	hide_score()


func _on_DeathTimer_timeout():
	show_score()
	$UI/Control/Defeat.visible = true
