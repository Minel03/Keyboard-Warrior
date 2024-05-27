extends Node2D

var Enemy = preload("res://Enemy.tscn")

onready var enemy_container = $EnemyContainer
onready var spawn_container = $SpawnContainer
onready var spawn_timer = $SpawnTimer
onready var difficulty_timer = $DifficultyTimer

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

var active_enemy = null
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
		if minutes >= 5:
			winner_screen.show()
			label.hide()
			spawn_timer.stop()
			difficulty_timer.stop()
			stop_timer()

func start_timer() -> void:
	game_duration_seconds = 0
	timer_running = true

func stop_timer() -> void:
	timer_running = false

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

		if active_enemy == null:
			find_new_active_enemy(key_typed)
		else:
			var prompt = active_enemy.get_prompt()
			var next_character = prompt.substr(current_letter_index, 1)
			if key_typed == next_character:
				print("successfully typed %s" % key_typed)
				correct_keystrokes += 1  # Increment correct keystrokes
				current_letter_index += 1
				active_enemy.set_next_character(current_letter_index)
				if current_letter_index == prompt.length():
					print("done")
					current_letter_index = -1
					correct_words.append(prompt)  # Track correctly typed words
					active_enemy.queue_free()
					active_enemy = null
					enemies_killed += 1
					score_value.text = str(enemies_killed)
			else:
				print("incorrectly typed %s instead of %s" % [key_typed, next_character])
				incorrect_keystrokes += 1  # Increment incorrect keystrokes


func _on_SpawnTimer_timeout():
	spawn_enemy()

func spawn_enemy():
	var enemy_instance = Enemy.instance()
	var spawns = spawn_container.get_children()
	var index = randi() % spawns.size()
	enemy_instance.global_position = spawns[index].global_position
	enemy_container.add_child(enemy_instance)
	enemy_instance.set_difficuty(difficulty)
	overall_words.append(enemy_instance.get_prompt())  # Track all produced words

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
		body.queue_free()
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
	life -= 1
	if life == 2:
		life3.hide()
	if life == 1:
		life2.hide()
	if life <= 0:
		game_over_screen.show()
		label.hide()
		spawn_timer.stop()
		difficulty_timer.stop()
		stop_timer()
		active_enemy = null
		current_letter_index = -1
		for enemy in enemy_container.get_children():
			enemy.queue_free()
	display_accuracy()  # Display accuracy when the game is over
	update_word_labels()  # Update the word labels
	update_score_label()  # Update the score label

func start_game():
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

func _on_PauseButton_pressed():
	Click_sound.play()
	var pause_instance = pause_scene.instance()
	add_child(pause_instance)
		
	get_tree().paused = true
	pause_instance.set_process_input(true)

func _on_Restart_pressed():
	get_tree().change_scene("res://Infinite.tscn")
