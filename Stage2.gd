extends Node2D

var Enemy = preload("res://Enemy2.tscn")
var Boss = preload("res://Boss.tscn")
var BossSpawn = preload("res://BossSpawn.tscn")
var Projectile = preload("res://Projectile.tscn")  # Preload the projectile scene

onready var freezesfx = $freeze_sfx
onready var doomsfx = $doom_sfx
onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var spawn_timer = $SpawnTimer
onready var boss_container = $BossContainer
onready var bossspawn_container = $BossSpawnContainer/Position2D
onready var boss_timer = $BossTimer
onready var bossenemy_container = $BossEnemyContainer
onready var after_boss = $AfterBoss
onready var difficulty_timer = $DifficultyTimer
onready var frozen_effect = $CanvasLayer/VBoxContainer/Frozen_Effect
onready var frozen_icon = $TextureRect3
onready var doom_icon = $TextureRect4
onready var portal1 = $Portal
onready var portal2 = $Portal2
onready var portal3 = $Portal3
onready var portal4 = $Portal4
onready var doomskill = $Doom
onready var hero = $Hero
onready var bossskill = $BossSkill
onready var attack_timer = $AttackTimer

onready var difficulty_value = $CanvasLayer/VBoxContainer/TopRowLeft2/TopRow2/DifficultyValue
onready var score_value = $CanvasLayer/VBoxContainer/TopRowLeft/EnemiesKilledValue
onready var skill_point_label = $CanvasLayer/VBoxContainer/TopRow3/SPValue
onready var label = $CanvasLayer/VBoxContainer
onready var game_over_screen = $CanvasLayer/GameOverScreen
onready var winner_screen = $CanvasLayer/CompleteScreen
onready var timer_label = $CanvasLayer/VBoxContainer/TopRowLeft/TopRow/TimerValue

var active_enemies: Array = []
var completed_enemies: Array = []  # Track completed enemies
var incomplete_enemies: Array = []  # Track incomplete enemies
var current_letter_index: int = -1
var boss_instance = null  # Variable to keep track of the boss instance
var boss_spawned = false  # Flag to indicate if a boss is spawned
var boss_spawn_canceled = false  # Add this line to declare a new variable

var current_spawn_index: int = 0
var difficulty: int = 6
var enemies_killed: int = 0
var skillpoint: int = 0

var game_duration_seconds: int = 0
var timer_running: bool = false
var timer_update: Timer = Timer.new()

var launch_projectile_flag = false
var skill_active = false  # Flag to track if a skill is active

func _process(delta):
	if launch_projectile_flag:
		hero.play("attack")
	else:
		hero.play("idle")
	if skillpoint == 0:
		frozen_icon.hide()
		doom_icon.hide()

func _ready() -> void:
	MusicManager.play_stage2music()
	add_child(timer_update)
	timer_update.connect("timeout", self, "update_timer")
	after_boss.connect("timeout", self, "_on_AfterBoss_timeout")
	start_game()

var ch2_2_scene = preload("res://story/ch2-2.tscn")
var ch2_3_scene = preload("res://story/ch2-3.tscn")
var ch2_4_scene = preload("res://story/ch2-4.tscn")
var ch2_end_scene = preload("res://story/Chapter2_End.tscn")

func update_timer() -> void:
	if timer_running:
		game_duration_seconds += 1
		var minutes = game_duration_seconds / 60
		var seconds = game_duration_seconds % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]
		#if minutes >= 10:
		#	winner_screen.show()
		#	label.hide()
		#	spawn_timer.stop()
		#	difficulty_timer.stop()
		#	stop_timer()
		if minutes == 4 and seconds == 55:
			pause_game_and_show_dialogue(ch2_2_scene)
		if minutes == 7 and seconds == 15:
			pause_game_and_show_dialogue(ch2_3_scene)
		if minutes == 9 and seconds == 45:
			pause_game_and_show_dialogue(ch2_4_scene)
		if minutes == 7 and seconds == 45:
			toggle_bossskill_visibility()
		if minutes == 9 and seconds == 55:
			boss_spawn_canceled = true  # Set the flag to true
			launch_projectile(boss_instance)
			portal1.hide()
			portal2.hide()
			portal3.hide()
			portal4.hide()
		if minutes == 9 and seconds == 56:
			label.hide()
			spawn_timer.stop()
			difficulty_timer.stop()
			stop_timer()
			pause_game_and_show_dialogue(ch2_end_scene)

func pause_game_and_show_dialogue(dialogue_scene):
	var dialogue_instance = dialogue_scene.instance()
	dialogue_instance.connect("dialogue_finished", self, "resume_game")
	add_child(dialogue_instance)
	get_tree().paused = true
	dialogue_instance.set_process_input(true)
	dialogue_instance.set_pause_mode(Node.PAUSE_MODE_PROCESS)
		
func resume_game():
	get_tree().paused = false

func start_timer() -> void:
	game_duration_seconds = 0
	timer_running = true

func stop_timer() -> void:
	timer_running = false

func find_new_active_enemy(typed_character: String):
	if skill_active:
		return  # Don't allow typing if a skill is active
	# Clear any previous active enemies
	active_enemies.clear()

	for enemy in enemy_container.get_children():
		if enemy == null or enemy in completed_enemies:
			continue
		
		# Check if the enemy has been removed from the scene
		if enemy.get_parent() == null:
			continue

		# Check if the enemy has the method `get_prompt`
		if not enemy.has_method("get_prompt"):
			continue
		
		var prompt = enemy.get_prompt()
		if prompt == null:
			continue

		var next_character = prompt.substr(0, 1)
		if next_character == typed_character:
			print("found new enemy that starts with %s" % next_character)
			active_enemies.append(enemy)
			current_letter_index = 1  # Reset the typing state
			enemy.set_next_character(current_letter_index)
			return

func _unhandled_input(event: InputEvent) -> void:
	if game_over_screen.visible:  # Check if the game is over
		return  # Ignore input if the game is over
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()
		
		# Check for the '1' key press to activate freeze()
		if typed_event.scancode == KEY_1 and skillpoint >= 1:
			skillpoint -= 1
			update_skill_point_label()
			freeze()
			return
		elif typed_event.scancode == KEY_2 and skillpoint >= 1:
			skillpoint -= 1
			update_skill_point_label()
			remove_random_enemies(5)
			return
		
		if skill_active:
			return  # Don't allow typing if a skill is active
		
		frozen_icon.hide()
		doom_icon.hide()

		if active_enemies.empty():
			find_new_active_enemy(key_typed)
		else:
			var found_enemy = false
			for enemy in active_enemies:
				var prompt = enemy.get_prompt()
				var next_character = prompt.substr(current_letter_index, 1)
				if key_typed == next_character:
					found_enemy = true
					print("successfully typed %s" % key_typed)
					current_letter_index += 1
					enemy.set_next_character(current_letter_index)
					if current_letter_index == prompt.length():
						print("done")
						current_letter_index = -1
						launch_projectile(enemy)  # Launch the projectile at the enemy
						active_enemies.erase(enemy)
						completed_enemies.append(enemy)  # Add the completed enemy to the list
						enemies_killed += 1
						score_value.text = str(enemies_killed)
						frozen_icon.show()
						doom_icon.show()
					break

			if not found_enemy:
				print("incorrectly typed %s" % key_typed)

func _on_SpawnTimer_timeout():
	spawn_enemy()

func spawn_enemy():
	if boss_spawned:
		return  # Do not spawn enemies if a boss is spawned
	var enemy_instance = Enemy.instance()
	var spawns = spawn_container.get_children()
	var index = randi() % spawns.size()
	enemy_instance.global_position = spawns[index].global_position
	enemy_container.add_child(enemy_instance)
	enemy_instance.set_difficulty(difficulty)
	
	var animation_player = enemy_instance.animation
	var animation_list = animation_player.get_animation_list()
	if animation_list.size() > 0:
		var random_animation_index = randi() % animation_list.size()
		var random_animation_name = animation_list[random_animation_index]
		animation_player.play(random_animation_name)
	else:
		print("No animations found in AnimationPlayer.")

func spawn_boss():
	if boss_instance == null:
		boss_instance = Boss.instance()
		var boss_spawn_point = bossspawn_container.global_position  # Get the global position of the spawn point
		boss_instance.global_position = boss_spawn_point  # Set the boss's position to the spawn point
		boss_container.add_child(boss_instance)
		boss_spawned = true  # Set the flag to true when a boss is spawned
		after_boss.start(5)  # Start the timer for 5 seconds

func spawn_bossenemy():
	var bossenemy_instance = BossSpawn.instance()
	var bossenemy_spawn = bossenemy_container.get_children()

	# Ensure the index is within the bounds of the spawns array (0 to 3)
	current_spawn_index = current_spawn_index % 4

	bossenemy_instance.global_position = bossenemy_spawn[current_spawn_index].global_position
	enemy_container.add_child(bossenemy_instance)
	bossenemy_instance.set_difficulty(difficulty)

	var animation_player = bossenemy_instance.animation
	var animation_list = animation_player.get_animation_list()
	if animation_list.size() > 0:
		var random_animation_index = randi() % animation_list.size()
		var random_animation_name = animation_list[random_animation_index]
		animation_player.play(random_animation_name)
	else:
		print("No animations found in AnimationPlayer.")

	# Update the index for the next spawn
	current_spawn_index += 1

func _on_DifficultyTimer_timeout():
	if difficulty >= 10:
		difficulty_timer.stop()
		difficulty = 10
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
	MusicManager.stop_stage2music()
	MusicManager.play_gameovermusic()
	frozen_effect.hide()
	game_over_screen.show()
	label.hide()
	spawn_timer.stop()
	boss_timer.stop()
	difficulty_timer.stop()
	stop_timer()
	for enemy in enemy_container.get_children():
		enemy.queue_free()
	current_letter_index = -1
	for enemy in enemy_container.get_children():
		enemy.queue_free()
	current_letter_index = -1

func start_game():
	bossskill.hide()
	portal1.hide()
	portal2.hide()
	portal3.hide()
	portal4.hide()
	doomskill.hide()
	game_over_screen.hide()
	winner_screen.hide()
	skillpoint = 2
	difficulty = 6
	enemies_killed = 0
	difficulty_value.text = str(difficulty)
	score_value.text = str(0)
	update_skill_point_label()  # Update skill point label at start
	randomize()
	spawn_timer.start()
	boss_timer.start()
	difficulty_timer.start()
	start_timer()
	timer_update.start(1)
	spawn_enemy()

func update_skill_point_label():
	print("Updating skill point label to %d" % skillpoint)  # Debugging print
	skill_point_label.text = str(skillpoint)

func _on_RestartButton_pressed():
	MusicManager.stop_gameovermusic()
	get_tree().change_scene("res://Stage2.tscn")

func _on_MenuButton_pressed():
	MusicManager.stop_gameovermusic()
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
	# Freeze enemies for 3 seconds
	for enemy in enemy_container.get_children():
		enemy.freeze()  # Call a freeze method on the enemy script

	frozen_effect.show()
	yield(get_tree().create_timer(3.0), "timeout")
	frozen_effect.hide()

	# Slow down enemies for 2 seconds
	for enemy in enemy_container.get_children():
		enemy.slow_down()  # Call a slow_down method on the enemy script

	yield(get_tree().create_timer(2.0), "timeout")

func remove_random_enemies(count: int):
	skill_active = true  # Set the skill active flag
	# Show and play the doomskill animation
	doomskill.show()
	doomsfx.play()
	doomskill.play("cast")
	yield(doomskill, "animation_finished")  # Wait for the doomskill animation to finish
	
	# After the doomskill animation finishes, remove enemies
	var enemies = enemy_container.get_children()
	for i in range(min(count, enemies.size())):
		enemies[i].queue_free()
	
	# Hide the doomskill after removing enemies
	doomskill.hide()
	skill_active = false  # Reset the skill active flag

func launch_projectile(target):
	var projectile_instance = Projectile.instance()
	projectile_instance.global_position = Vector2(309, 752)
	add_child(projectile_instance)
	projectile_instance.target = target
	launch_projectile_flag = true
	attack_timer.start(0.7)

func _on_attack_timer_timeout():
	launch_projectile_flag = false

func _on_BossTimer_timeout():
	spawn_boss()

func _on_AfterBoss_timeout():
	if boss_spawn_canceled:
		return
	yield(get_tree().create_timer(1.0), "timeout")  # Wait for 1 second before showing the first portal
	portal1.show()
	portal1.play("idle")
	yield(get_tree().create_timer(1.0), "timeout")  # Wait for 1 second before showing the second portal
	portal2.show()
	portal2.play("idle")
	yield(get_tree().create_timer(1.0), "timeout")  # Wait for 1 second before showing the third portal
	portal3.show()
	portal3.play("idle")
	yield(get_tree().create_timer(1.0), "timeout")  # Wait for 1 second before showing the fourth portal
	portal4.show()
	portal4.play("idle")
	# Check if the boss spawn has been canceled
	if not boss_spawn_canceled:
		spawn_bossenemy()
	
func toggle_bossskill_visibility() -> void:
	for i in range(20):  # Adjust the number of times you want to show/hide the BossSkill
		bossskill.show()
		yield(get_tree().create_timer(0.5), "timeout")  # Wait for 0.5 seconds (adjust as needed)
		bossskill.hide()
		yield(get_tree().create_timer(0.5), "timeout")  # Wait for 0.5 seconds (adjust as needed)


