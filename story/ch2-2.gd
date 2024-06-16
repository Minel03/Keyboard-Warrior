extends Control

var images = [
	preload("res://assets/intro/2-1.png")
]

var dialogues = [
	"The climax of the battle arrives with the emergence of the boss golem, a colossal monstrosity crafted from the very essence of darkness. Ethan's strength is waning, but his determination burns brighter than ever. With each keystroke, he unleashes powerful spells of light, aiming to bring down the towering foe.",
]

var current_index = 0

onready var image_rect = $TextureRect
onready var dialogue_label = $Label
onready var animation_player = $AnimationPlayer
onready var transition_timer = $transitiontimer

signal dialogue_finished

func _ready():
	update_slide()
	
func update_slide():
	if current_index < images.size() and current_index < dialogues.size():
		image_rect.texture = images[current_index]
		dialogue_label.text = dialogues[current_index]
		start_text_scroll()
	else:
		resume_stage()
	
func resume_stage():
	emit_signal("dialogue_finished")
	queue_free()

func start_text_scroll():
	animation_player.play("text_slide")
	transition_timer.start(20)
	
func _on_transitiontimer_timeout():
	current_index += 1
	update_slide()

var pause_scene = preload("res://Pause.tscn")
onready var Click_sound = get_node("/root/ClickSound")

func _on_Pause_pressed():
	Click_sound.play()
	var pause_instance = pause_scene.instance()
	add_child(pause_instance)
		
	get_tree().paused = true
	pause_instance.set_process_input(true)
