extends KinematicBody2D

onready var animation = $AnimationPlayer
onready var death_animation = $DeathAnimation
onready var death_sound = $enemydeath_sound
export (Color) var blue = Color("#4682b4")
export (Color) var green = Color("#639765")
export (Color) var red = Color("#a65455")

export (float) var speed = 0.5
var original_speed: float = 0.5  # Store the original speed for resetting

onready var prompt = $RichTextLabel
onready var prompt_text = prompt.text

func _ready() -> void:
	add_to_group("enemies")
	prompt_text = PromptList2.get_prompt()
	prompt.parse_bbcode(set_center_tags(prompt_text))
	original_speed = speed  # Store the original speed

func play_death_animation():
	death_sound.play()
	death_animation.play("death")

func _on_death_animation_finished():
	if death_animation.is_playing():
		queue_free()

func _physics_process(delta: float) -> void:
	global_position.y += speed

func set_difficulty(difficulty: int) -> void:
	handle_difficulty_increased(difficulty)

func handle_difficulty_increased(new_difficulty: int) -> void:
	var new_speed = original_speed + (0.125 * new_difficulty)
	speed = clamp(new_speed, original_speed, 3)
	# Update speed without changing animation

func get_prompt() -> String:
	return prompt_text

func set_next_character(next_character_index: int) -> void:
	var blue_text = get_bbcode_color_tag(blue) + prompt_text.substr(0, next_character_index) + get_bbcode_end_color_tag()
	var green_text = get_bbcode_color_tag(green) + prompt_text.substr(next_character_index, 1) + get_bbcode_end_color_tag()
	var red_text = ""
	
	if next_character_index != prompt_text.length():
		red_text = get_bbcode_color_tag(red) + prompt_text.substr(next_character_index + 1, prompt_text.length() - next_character_index + 1) + get_bbcode_end_color_tag()
	
	prompt.parse_bbcode(set_center_tags(blue_text + green_text + red_text))

func set_center_tags(string_to_center: String) -> String:
	return "[center]" + string_to_center + "[/center]"

func get_bbcode_color_tag(color: Color) -> String:
	return "[color=#" + color.to_html(false) + "]"
	
func get_bbcode_end_color_tag() -> String:
	return "[/color]"

func freeze() -> void:
	speed = 0.0  # Set speed to 0 to freeze the enemy

func slow_down() -> void:
	speed = original_speed * 0.5  # Slow down the enemy to half of its original speed
