extends PanelContainer

onready var leaderboard_label = $VBoxContainer/LeaderboardLabel
onready var labels_label = $VBoxContainer/Labels
onready var rankings_label = $VBoxContainer/Rankings

func _ready():
	update_leaderboard_display()

func update_leaderboard_display():
	rankings_label.text = ""  # Clear previous entries
	var leaderboard_data = Leaderboard.leaderboard_data
	var current_player_name = Global.player_name  # Assume Global.player_name holds the current player's name
	
	for i in range(leaderboard_data.size()):
		var entry = leaderboard_data[i]
		var rank = str(i + 1)
		var name = entry["name"]
		var score = str(entry["score"])
		var accuracy = "%.2f%%" % entry["accuracy"]
		
		# Format the entry
		var entry_text = "%-7s %-9s %-7s %-6s" % [rank, name, score, accuracy]
		
		# Check if the entry belongs to the current player
		if name == current_player_name:
			entry_text = entry_text  # Bold the current player's entry
		
		rankings_label.text += entry_text + "\n"


func _on_Menu_pressed():
	MusicManager.stop_gameovermusic()
	get_tree().change_scene("res://StageMenu.tscn")
