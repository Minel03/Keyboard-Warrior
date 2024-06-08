extends Control

var images = [
	preload("res://assets/intro/4.png"),
]

var dialogues = [
	"Day and night blur together as Ethan stands vigilant atop the castle battlements, tirelessly typing away to fend off the relentless hordes of Cancer. His fingers move with practiced precision, his mind focused solely on the task at hand. There is no time for rest, no respite from the unending assault."
]

var current_index = 0

onready var image_rect = $TextureRect
onready var dialogue_label = $Label
onready var animation_player = $AnimationPlayer
onready var transition_timer = $transitiontimer

func _ready():
	update_slide()
	
var clear_scene = preload("res://stage1_clear.tscn")

func update_slide():
	if current_index < images.size() and current_index < dialogues.size():
		image_rect.texture = images[current_index]
		dialogue_label.text = dialogues[current_index]
		start_text_scroll()
	else:
		cleared_stage()
	
func cleared_stage():
	Click_sound.play()
	var cleared_instance = clear_scene.instance()
	add_child(cleared_instance)

func start_text_scroll():
	animation_player.play("text_slide")
	transition_timer.start(25)

func _on_transitiontimer_timeout():
	current_index += 1
	update_slide()

func _on_Button_pressed():
	cleared_stage()

var pause_scene = preload("res://Pause.tscn")
onready var Click_sound = get_node("/root/ClickSound")

func _on_Pause_pressed():
	Click_sound.play()
	var pause_instance = pause_scene.instance()
	add_child(pause_instance)
		
	get_tree().paused = true
	pause_instance.set_process_input(true)
