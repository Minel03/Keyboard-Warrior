extends Control

var images = [
	preload("res://assets/intro/6.png"),
	preload("res://assets/intro/Black_colour.jpg"),
	preload("res://assets/intro/Black_colour.jpg")
]

var dialogues = [
	"Ethan collapses to his knees, exhausted but victorious. The castle walls still stand, a testament to his unwavering defense. The people of the castle erupt in cheers, their hope rekindled by the defeat of the monstrous golem. But as the dust settles, Ethan knows the battle is far from over. Shadows still lurk in the corners of the realm, and the threat of darkness looms ever-present.",
	"As he rises to his feet, Ethan gazes out over the battlements, his eyes scanning the horizon. The victory over the golem is a significant triumph, but it is merely a respite in the ongoing war. With renewed determination, he prepares to face the challenges that lie ahead, ready to defend the Castle of Radiance until his last breath.",
	"To Be Continued . . ."
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
		get_tree().change_scene("res://MainMenu.tscn")
	
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

onready var Click_sound = get_node("/root/ClickSound")
