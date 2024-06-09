extends Control

var images = [
	preload("res://assets/intro/5.png")
]

var dialogues = [
	"As the days turn into weeks and the weeks into months, Ethan's resolve remains unbroken. He witnesses the bravery and sacrifice of his fellow defenders, their spirits unwavering in the face of overwhelming odds. But for every enemy vanquished, a dozen more take its place, an endless tide of darkness that threatens to consume them all.",
]

var current_index = 0

onready var image_rect = $TextureRect
onready var dialogue_label = $Label
onready var animation_player = $AnimationPlayer
onready var transition_timer = $transitiontimer

func _ready():
	MusicManager.stop_menumusic()
	update_slide()
	
func update_slide():
	if current_index < images.size() and current_index < dialogues.size():
		image_rect.texture = images[current_index]
		dialogue_label.text = dialogues[current_index]
		start_text_scroll()
	else:
		start_stage()
	
func start_stage():
	get_tree().change_scene("res://Stage2.tscn")

func start_text_scroll():
	animation_player.play("text_slide")
	transition_timer.start(20)

func _on_transitiontimer_timeout():
	current_index += 1
	update_slide()

func _on_Button_pressed():
	start_stage()

var pause_scene = preload("res://Pause.tscn")
onready var Click_sound = get_node("/root/ClickSound")

func _on_Pause_pressed():
	Click_sound.play()
	var pause_instance = pause_scene.instance()
	add_child(pause_instance)
		
	get_tree().paused = true
	pause_instance.set_process_input(true)
