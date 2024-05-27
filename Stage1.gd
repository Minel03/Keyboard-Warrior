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

var active_enemy = null
var current_letter_index: int = -1

var difficulty: int = 0
var enemies_killed: int = 0

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
				current_letter_index += 1
				active_enemy.set_next_character(current_letter_index)
				if current_letter_index == prompt.length():
					print("done")
					current_letter_index = -1
					active_enemy.queue_free()
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
	enemy_instance.set_difficulty(difficulty)
	
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
	game_over()

func game_over():
	game_over_screen.show()
	label.hide()
	spawn_timer.stop()
	difficulty_timer.stop()
	stop_timer()
	active_enemy = null
	current_letter_index = -1
	for enemy in enemy_container.get_children():
		enemy.queue_free()

func start_game():
	game_over_screen.hide()
	winner_screen.hide()
	difficulty = 1
	enemies_killed = 0
	difficulty_value.text = str(difficulty)
	score_value.text = str(0)
	randomize()
	spawn_timer.start()
	difficulty_timer.start()
	start_timer()
	timer_update.start(1)
	spawn_enemy()

func _on_RestartButton_pressed():
	get_tree().change_scene("res://Stage1.tscn")

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
