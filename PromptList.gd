extends Node

var words = [
	"great", 
	"work"
]

func get_prompt() -> String:
	var word_index = randi() % words.size()
	
	var word = words[word_index]
	
	var actual_word = word.substr(0, 1).to_upper() + word.substr(1).to_lower()
	
	
	return actual_word
