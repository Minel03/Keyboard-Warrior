extends PanelContainer

onready var name_input = $VBoxContainer/NameInput
onready var difficulty_input = $VBoxContainer/DifficultyInput
onready var difficulty_slider = $VBoxContainer/DifficultySlider
onready var start_button = $VBoxContainer/Startbutton

signal start_game(name, difficulty)

func _ready():
	difficulty_input.connect("text_changed", self, "_on_DifficultyInput_text_changed")
	difficulty_slider.connect("value_changed", self, "_on_DifficultySlider_value_changed")
	start_button.connect("pressed", self, "_on_StartButton_pressed")

	# Initialize slider and input with default values
	difficulty_slider.value = 0
	difficulty_input.text = str(int(difficulty_slider.value))

func _on_DifficultyInput_text_changed(new_text):
	# Validate the input and update the slider value
	var new_value = int(new_text)
	if new_value >= difficulty_slider.min_value and new_value <= difficulty_slider.max_value:
		difficulty_slider.value = new_value
	else:
		# Handle invalid input (e.g., show an error message)
		print("Invalid difficulty value entered:", new_text)

func _on_DifficultySlider_value_changed(value):
	# Update the input text with the slider value
	difficulty_input.text = str(int(value))

func _on_StartButton_pressed():
	var player_name = name_input.text
	var starting_difficulty = int(difficulty_slider.value)
	emit_signal("start_game", player_name, starting_difficulty)
	self.hide()  # Hide the start screen when the game starts
