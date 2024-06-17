extends Node2D

# Load the StartScreen scene
onready var start_screen = $CanvasLayer/StartScreen

var Enemy = preload("res://InfiniteEnemy.tscn")
var Projectile = preload("res://Projectile.tscn")  # Preload the projectile scene

onready var freezesfx = $freeze_sfx
onready var doomsfx = $doom_sfx
onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var spawn_timer = $SpawnTimer
onready var difficulty_timer = $DifficultyTimer
onready var hero = $Hero
onready var attack_timer = $AttackTimer

onready var difficulty_value = $CanvasLayer/VBoxContainer/TopRowLeft2/TopRow2/DifficultyValue
onready var score_value = $CanvasLayer/VBoxContainer/TopRowLeft/EnemiesKilledValue
onready var skill_point_label = $CanvasLayer/VBoxContainer/TopRow3/SPValue
onready var label = $CanvasLayer/VBoxContainer
onready var game_over_screen = $CanvasLayer/GameOverScreen
onready var winner_screen = $CanvasLayer/CompleteScreen
onready var timer_label = $CanvasLayer/VBoxContainer/TopRowLeft/TopRow/TimerValue
onready var frozen_effect = $CanvasLayer/VBoxContainer/Frozen_Effect
onready var frozen_icon = $TextureRect3
onready var doom_icon = $TextureRect4
onready var doomskill = $Doom
onready var score_value_end = $CanvasLayer/GameOverScreen/CenterContainer/VBoxContainer/TopRowLeft/ScoreValue
onready var accuracy_value = $CanvasLayer/GameOverScreen/CenterContainer/VBoxContainer/TopRowLeft2/AccuracyValue
onready var words_value = $CanvasLayer/GameOverScreen/CenterContainer/VBoxContainer/TopRowLeft3/WordsValue

var active_enemies: Array = []
var completed_enemies: Array = []  # Track completed enemies
var incomplete_enemies: Array = []  # Track incomplete enemies
var current_letter_index: int = -1
var correct_keystrokes: int = 0
var incorrect_keystrokes: int = 0
var correct_words: Array = []
var overall_words: Array = []

var difficulty: int = 0
var enemies_killed: int = 0
var skillpoint: int = 0
var life: int = 3

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
	else:
		frozen_icon.show()
		doom_icon.show()

func _ready() -> void:
	MusicManager.stop_menumusic()
	MusicManager.play_infinitemusic()
	add_child(timer_update)
	timer_update.connect("timeout", self, "update_timer")
	
	# Debug print to check if the start_screen is found
	print("Start screen: ", start_screen)
	
	start_screen.connect("start_game", self, "_on_StartGame")
	start_screen.show()  # Show the start screen when the game starts
		
	# Hide the leaderboard panel initially
	$CanvasLayer/LeaderBoard.hide()

func _on_StartGame(player_name, starting_difficulty):
	Global.player_name = player_name  # Assuming you have a global variable for the player's name
	difficulty = starting_difficulty
	start_game()

func update_timer() -> void:
	if timer_running:
		game_duration_seconds += 1
		var minutes = game_duration_seconds / 60
		var seconds = game_duration_seconds % 60
		timer_label.text = "%02d:%02d" % [minutes, seconds]

func start_timer() -> void:
	game_duration_seconds = 0
	timer_running = true

func stop_timer() -> void:
	timer_running = false

func find_new_active_enemy(typed_character: String):
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
					correct_keystrokes += 1
					current_letter_index += 1
					enemy.set_next_character(current_letter_index)
					if current_letter_index == prompt.length():
						print("done")
						current_letter_index = -1
						correct_words.append(prompt)  # Track correctly typed words
						launch_projectile(enemy)  # Launch the projectile at the enemy
						active_enemies.erase(enemy)
						completed_enemies.append(enemy)  # Add the completed enemy to the list
						enemies_killed += 1
						score_value.text = str(enemies_killed)
						check_skill_point()
					break

			if not found_enemy:
				print("incorrectly typed %s" % key_typed)
				incorrect_keystrokes += 1

func check_skill_point():
	if enemies_killed % 10 == 0:  # Every 10 enemies killed
		skillpoint += 1
		update_skill_point_label()

func _on_SpawnTimer_timeout():
	spawn_enemy()

func spawn_enemy():
	var enemy_instance = Enemy.instance()
	var spawns = spawn_container.get_children()
	var index = randi() % spawns.size()
	enemy_instance.global_position = spawns[index].global_position
	enemy_container.add_child(enemy_instance)
	enemy_instance.set_difficulty(difficulty)
	overall_words.append(enemy_instance.get_prompt())  # Track all produced words
	
	var animation_player = enemy_instance.animation
	var animation_list = animation_player.get_animation_list()
	if animation_list.size() > 0:
		var random_animation_index = randi() % animation_list.size()
		var random_animation_name = animation_list[random_animation_index]
		animation_player.play(random_animation_name)
	else:
		print("No animations found in AnimationPlayer.")

func _on_DifficultyTimer_timeout():
	if difficulty >= 100:
		difficulty_timer.stop()
		difficulty = 100
		return

	difficulty += 1
	GlobalSignals.emit_signal("difficulty_increased", difficulty)
	print("Difficulty increased to %d" % difficulty)
	var new_wait_time = spawn_timer.wait_time - 0.2
	spawn_timer.wait_time = clamp(new_wait_time, 1, spawn_timer.wait_time)
	difficulty_value.text = str(difficulty)

func _on_LoseArea_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):  # Check if the body is in the 'enemies' group
		var enemy = body
		for projectile in get_tree().get_nodes_in_group("projectiles"):
			if projectile.target == enemy:
				projectile.queue_free()  # Remove the projectile associated with the enemy
				break

		# Ensure that the enemy is still valid before removing it
		if enemy and enemy.is_inside_tree():
			enemy.queue_free()  # Remove the enemy
			if enemy in incomplete_enemies:
				incomplete_enemies.erase(enemy)  # Remove from incomplete enemies if present
			completed_enemies.append(enemy)  # Add the completed enemy to the list
			game_over()  # Always call game_over() after checking the enemy

func calculate_accuracy() -> float:
	var total_keystrokes = correct_keystrokes + incorrect_keystrokes
	if total_keystrokes == 0:
		return 0.0
	return float(correct_keystrokes) / total_keystrokes * 100.0

func display_accuracy():
	var accuracy = calculate_accuracy()
	print("Typing Accuracy: %.2f%%" % accuracy)
	# Optionally, update a label in your UI to show accuracy
	accuracy_value.text = "%.2f%%" % accuracy

func update_score_label():
	score_value_end.text = str(enemies_killed)

func update_word_labels():
	var correct_word_count = correct_words.size()
	var overall_word_count = overall_words.size()
	words_value.text = "%d / %d" % [correct_word_count, overall_word_count]

func game_over():
	MusicManager.stop_infinitemusic()
	MusicManager.play_gameovermusic()
	game_over_screen.show()
	label.hide()
	spawn_timer.stop()
	difficulty_timer.stop()
	stop_timer()
	for enemy in enemy_container.get_children():
		enemy.queue_free()
	current_letter_index = -1
	for enemy in enemy_container.get_children():
		enemy.queue_free()
	display_accuracy()  # Display accuracy when the game is over
	update_word_labels()  # Update the word labels
	update_score_label()  # Update the score label
	
	# Add entry to the leaderboard
	Leaderboard.add_entry(Global.player_name, enemies_killed, correct_keystrokes, incorrect_keystrokes)
	show_leaderboard()

func start_game():
	hero.play("idle")
	game_over_screen.hide()
	$CanvasLayer/LeaderBoard.hide()  # Hide the leaderboard panel when the game starts
	difficulty = difficulty
	skillpoint = 0
	enemies_killed = 0
	difficulty_value.text = str(difficulty)
	score_value.text = str(0)
	update_skill_point_label()  # Update skill point label at start
	randomize()
	spawn_timer.start()
	difficulty_timer.start()
	start_timer()
	timer_update.start(1)
	spawn_enemy()
	correct_keystrokes = 0  # Reset correct keystrokes
	incorrect_keystrokes = 0  # Reset incorrect keystrokes

func show_leaderboard():
	var leaderboard_panel = $CanvasLayer/LeaderBoard
	leaderboard_panel.update_leaderboard_display()  # Call update_leaderboard_display() on the PanelContainer

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

func update_skill_point_label():
	print("Updating skill point label to %d" % skillpoint)  # Debugging print
	skill_point_label.text = str(skillpoint)

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

func _on_MenuButton_pressed():
	MusicManager.stop_gameovermusic()
	get_tree().change_scene("res://StageMenu.tscn")

var pause_scene = preload("res://Pause.tscn")
onready var Click_sound = get_node("/root/ClickSound")

func launch_projectile(target):
	var projectile_instance = Projectile.instance()
	projectile_instance.global_position = Vector2(309, 752)
	add_child(projectile_instance)
	projectile_instance.target = target
	launch_projectile_flag = true
	attack_timer.start(0.7)

func _on_attack_timer_timeout():
	launch_projectile_flag = false

func _on_PauseButton_pressed():
	Click_sound.play()
	var pause_instance = pause_scene.instance()
	add_child(pause_instance)
		
	get_tree().paused = true
	pause_instance.set_process_input(true)

func _on_Restart_pressed():
	MusicManager.stop_gameovermusic()
	get_tree().change_scene("res://Infinite.tscn")

func _on_LeaderBoard_pressed():
	show_leaderboard()
	$CanvasLayer/LeaderBoard.show()
