extends Control

var images = [
	preload("res://assets/intro/1.png"),
	preload("res://assets/intro/2.png"),
	preload("res://assets/intro/3.png"),
]

var dialogues = [
	"In the realm of Aetheria, where darkness holds sway, lies the Castle of Radiance – the last beacon of hope against the relentless onslaught of Cancer.",
	"Within its walls resides a boy named Ethan, who, in a twist of fate, was reincarnated as a Keyboard Warrior. Tasked with protecting the castle from the never-ending waves of enemies, Ethan's sole purpose is to defend its inhabitants until his last breath.",
	"From the moment Ethan's consciousness awakens in his new form, he understands his singular mission. With each keystroke, he conjures spells of light to repel the encroaching darkness. The people of the castle look to him as their guardian, their last line of defense against the horrors that besiege them.",
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
	get_tree().change_scene("res://Stage1.tscn")

func start_text_scroll():
	animation_player.play("text_slide")
	if current_index == 0:
		transition_timer.start(20)
	else:
		transition_timer.start(25)

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
