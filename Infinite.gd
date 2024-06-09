extends Node2D

var Enemy = preload("res://InfiniteEnemy.tscn")
var Projectile = preload("res://Projectile.tscn")  # Preload the projectile scene

onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var spawn_timer = $SpawnTimer
onready var difficulty_timer = $DifficultyTimer
onready var hero = $Hero
onready var attack_timer = $AttackTimer

onready var difficulty_value = $CanvasLayer/VBoxContainer/TopRowLeft2/TopRow2/DifficultyValue
onready var score_value = $CanvasLayer/VBoxContainer/TopRowLeft/EnemiesKilledValue
onready var label = $CanvasLayer/VBoxContainer
onready var game_over_screen = $CanvasLayer/GameOverScreen
onready var winner_screen = $CanvasLayer/CompleteScreen
onready var timer_label = $CanvasLayer/VBoxContainer/TopRowLeft/TopRow/TimerValue
onready var life2 = $Life2
onready var life3 = $Life3
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
var life: int = 3

var game_duration_seconds: int = 0
var timer_running: bool = false
var timer_update: Timer = Timer.new()

var launch_projectile_flag = false

func _process(delta):
	if launch_projectile_flag:
		hero.play("attack")
	else:
		hero.play("idle")

func _ready() -> void:
	add_child(timer_update)
	timer_update.connect("timeout", self, "update_timer")
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
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var typed_event = event as InputEventKey
		var key_typed = PoolByteArray([typed_event.unicode]).get_string_from_utf8()

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
					break

			if not found_enemy:
				print("incorrectly typed %s" % key_typed)
				incorrect_keystrokes += 1

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

func start_game():
	hero.play("idle")
	game_over_screen.hide()
	difficulty = 0
	enemies_killed = 0
	difficulty_value.text = str(0)
	score_value.text = str(0)
	randomize()
	spawn_timer.start()
	difficulty_timer.start()
	start_timer()
	timer_update.start(1)
	spawn_enemy()
	correct_keystrokes = 0  # Reset correct keystrokes
	incorrect_keystrokes = 0  # Reset incorrect keystrokes

func _on_MenuButton_pressed():
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
	get_tree().change_scene("res://Infinite.tscn")
