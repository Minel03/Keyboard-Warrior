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

func add_entry(name, score, correct_words):
	var new_entry = {"name": name, "score": score, "correct_words": correct_words}
	leaderboard_data.append(new_entry)
	leaderboard_data.sort_custom(Leaderboard, "sort_entries")
	if leaderboard_data.size() > max_entries:
		leaderboard_data.pop_back()
	save_leaderboard()
	
	return new_entry  # Return the new entry for potential highlighting

static func sort_entries(a, b):
	if a["score"] != b["score"]:
		return b["score"] - a["score"]
	else:
		return b["correct_words"] - a["correct_words"]
