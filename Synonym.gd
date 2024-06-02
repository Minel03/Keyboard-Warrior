extends Node2D

var Enemy = preload("res://Enemy2.tscn")
var Boss = preload("res://Boss.tscn")
var Projectile = preload("res://Projectile.tscn")  # Preload the projectile scene


onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var spawn_timer = $SpawnTimer
onready var boss_container = $BossContainer
onready var bossspawn_container = $BossSpawnContainer/Position2D
onready var boss_timer = $BossTimer
onready var difficulty_timer = $DifficultyTimer

onready var difficulty_value = $CanvasLayer/VBoxContainer/TopRowLeft2/TopRow2/DifficultyValue
onready var score_value = $CanvasLayer/VBoxContainer/TopRowLeft/EnemiesKilledValue
<<<<<<< Updated upstream:Synonym.gd
=======
onready var skill_point_label = $CanvasLayer/VBoxContainer/TopRow3/SPValue
onready var label = $CanvasLayer/VBoxContainer
>>>>>>> Stashed changes:Stage2.gd
onready var game_over_screen = $CanvasLayer/GameOverScreen

var active_enemy = null
var completed_enemies: Array = []  # Track completed enemies
var current_letter_index: int = -1

var difficulty: int = 0
var enemies_killed: int = 0
var skillpoint: int = 0


func _ready() -> void:
	start_game()


func find_new_active_enemy(typed_character: String):
	for enemy in enemy_container.get_children():
		var prompt = enemy.get_prompt()
		var next_character = prompt.substr(0, 1)
		if next_character == typed_character:
			print("found new enemy that starts with %s" % next_character)
			active_enemy = enemy
			current_letter_index = 1
			active_enemy.set_next_character(current_letter_index)
			return


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
<<<<<<< Updated upstream:Synonym.gd
=======
		# Check for the '1' key press to activate freeze()
		if typed_event.scancode == KEY_1:
			freeze()
			return
		elif typed_event.scancode == KEY_2:
			place_barrier(5)
			return
		elif typed_event.scancode == KEY_3:
			remove_random_enemies(5)
		
>>>>>>> Stashed changes:Stage2.gd
		if active_enemy == null:
			find_new_active_enemy(key_typed)
		else:
			var prompt = active_enemy.get_prompt()
			var next_character = prompt.substr(current_letter_index, 1)
			if key_typed == next_character:
				print("successfully typed %s" % key_typed)
				current_letter_index += 1
				active_enemy.set_next_character(current_letter_index)
				if current_letter_index == prompt.length():
					print("done")
					current_letter_index = -1
					launch_projectile(active_enemy)  # Launch the projectile at the enemy
					active_enemy = null
					enemies_killed += 1
					score_value.text = str(enemies_killed)
			else:
				print("incorrectly typed %s instead of %s" % [key_typed, next_character])


func _on_SpawnTimer_timeout():
	spawn_enemy()


func spawn_enemy():
	var enemy_instance = Enemy.instance()
	var spawns = spawn_container.get_children()
	var index = randi() % spawns.size()
	enemy_instance.global_position = spawns[index].global_position
	enemy_container.add_child(enemy_instance)
	enemy_instance.set_difficuty(difficulty)

func spawn_boss():
	var boss_instance = Boss.instance()
	var boss_spawn_point = bossspawn_container.global_position  # Get the global position of the spawn point
	boss_instance.global_position = boss_spawn_point  # Set the boss's position to the spawn point
	boss_container.add_child(boss_instance)

func _on_DifficultyTimer_timeout():
	if difficulty >= 20:
		difficulty_timer.stop()
		difficulty = 20
		return
	
	difficulty += 1
	GlobalSignals.emit_signal("difficulty_increased", difficulty)
	print("Difficulty increased to %d" % difficulty)
	var new_wait_time = spawn_timer.wait_time - 0.2
	spawn_timer.wait_time = clamp(new_wait_time, 1, spawn_timer.wait_time)
	difficulty_value.text = str(difficulty)


func _on_LoseArea_body_entered(body: Node) -> void:
	game_over()


func game_over():
	game_over_screen.show()
	spawn_timer.stop()
	boss_timer.stop()
	difficulty_timer.stop()
	active_enemy = null
	current_letter_index = -1
	for enemy in enemy_container.get_children():
		enemy.queue_free()


func start_game():
	game_over_screen.hide()
<<<<<<< Updated upstream:Synonym.gd
	difficulty = 0
=======
	winner_screen.hide()
	skillpoint = 10
	difficulty = 6
>>>>>>> Stashed changes:Stage2.gd
	enemies_killed = 0
	difficulty_value.text = str(0)
	score_value.text = str(0)
	update_skill_point_label()  # Update skill point label at start
	randomize()
	spawn_timer.start()
	boss_timer.start()
	difficulty_timer.start()
	spawn_enemy()

<<<<<<< Updated upstream:Synonym.gd
=======
func update_skill_point_label():
	print("Updating skill point label to %d" % skillpoint)  # Debugging print
	skill_point_label.text = str(skillpoint)
>>>>>>> Stashed changes:Stage2.gd

func _on_RestartButton_pressed():
	start_game()


func _on_MenuButton_pressed():
<<<<<<< Updated upstream:Synonym.gd
	get_tree().change_scene("res://MainMenu.tscn")
=======
	get_tree().change_scene("res://StageMenu.tscn")

var pause_scene = preload("res://Pause.tscn")
onready var Click_sound = get_node("/root/ClickSound")

func _on_PauseButton_pressed():
	Click_sound.play()
	var pause_instance = pause_scene.instance()
	add_child(pause_instance)
		
	get_tree().paused = true
	pause_instance.set_process_input(true)

func freeze():
	if skillpoint >= 3:
		skillpoint -= 3
		update_skill_point_label()
		print("Skill points after using freeze: %d" % skillpoint)  # Debugging print
		# Freeze enemies for 3 seconds
		for enemy in enemy_container.get_children():
			enemy.freeze()  # Call a freeze method on the enemy script
		yield(get_tree().create_timer(3.0), "timeout")
		# Slow down enemies for 2 seconds
		for enemy in enemy_container.get_children():
			enemy.slow_down()  # Call a slow_down method on the enemy script
		yield(get_tree().create_timer(2.0), "timeout")

func place_barrier(health: int):
	if skillpoint >= 3:
		skillpoint -= 3
		update_skill_point_label()
		print("Skill points after placing barrier: %d" % skillpoint)  # Debugging print
		barrier_health = health
		barrier_active = true

func remove_random_enemies(count: int):
	if skillpoint >= 4:
		skillpoint -= 4
		update_skill_point_label()
		print("Skill points after removing enemies: %d" % skillpoint)  # Debugging print
	var enemies = enemy_container.get_children()
	for i in range(min(count, enemies.size())):
		enemies[i].queue_free()

func launch_projectile(target):
	var projectile_instance = Projectile.instance()
	projectile_instance.global_position = Vector2(309, 752)
	add_child(projectile_instance)
	projectile_instance.target = target

func _on_BossTimer_timeout():
	spawn_boss()
>>>>>>> Stashed changes:Stage2.gd
