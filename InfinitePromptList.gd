extends Node

#List from here https://www.dictionary.com/learn/word-lists/general/H23wqeCDqyg
var words = [
	"Fear",
	"Evil",
	"Dark",
	"Hide",
	"Claw",
	"Fang",
	"Harm",
	"Doom",
	"Scum",
	"Hate",
	"Grim",
	"Beast",
	"Fiend",
	"Terror",
	"Demon",
	"Chasm",
	"Grasp",
	"Ghoul",
	"Looms",
	"Abyss",
	"Curse",
	"Shadow",
	"Horror",
	"Wicked",
	"Malice",
	"Haunts",
	"Menace",
	"Savage",
	"Abduct",
	"Tyrant",
	"Monster",
	"Cruelty",
	"Abyssal",
	"Schemer",
	"Voracious",
	"Darkness",
	"Hellish",
	"Torment",
	"Predator",
	"Malefic"
]

func get_prompt() -> String:
	var word_index = randi() % words.size()
	
	var word = words[word_index]
	
	var actual_word = word.substr(0, 1).to_lower() + word.substr(1).to_lower()
	
	
	return actual_word
