extends Node

var max_entries = 10
var leaderboard_data = []

func _ready():
	load_leaderboard()

func load_leaderboard():
	var save_path = "user://leaderboard.save"
	var file = File.new()
	if file.file_exists(save_path):
		file.open(save_path, File.READ)
		leaderboard_data = parse_json(file.get_as_text())
		file.close()
	else:
		leaderboard_data = []

func save_leaderboard():
	var save_path = "user://leaderboard.save"
	var file = File.new()
	file.open(save_path, File.WRITE)
	file.store_string(to_json(leaderboard_data))
	file.close()

func calculate_accuracy(correct_keystrokes, incorrect_keystrokes) -> float:
	var total_keystrokes = correct_keystrokes + incorrect_keystrokes
	if total_keystrokes == 0:
		return 0.0
	return float(correct_keystrokes) / total_keystrokes * 100.0

func add_entry(name, score, correct_keystrokes, incorrect_keystrokes):
	var accuracy = calculate_accuracy(correct_keystrokes, incorrect_keystrokes)
	var new_entry = {"name": name, "score": score, "accuracy": accuracy}
	leaderboard_data.append(new_entry)
	leaderboard_data.sort_custom(self, "sort_entries")
	if leaderboard_data.size() > max_entries:
		leaderboard_data.pop_back()
	save_leaderboard()

	return new_entry  # Return the new entry for potential highlighting

static func sort_entries(a, b):
	return a["score"] > b["score"] if a["score"] != b["score"] else a["accuracy"] > b["accuracy"]
		
