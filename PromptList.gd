extends Node

var words = [
	"Book", 
	"Fish",
	"Lamp",
	"Tree",
	"Hand",
	"Gold",
	"Ball",
	"Moon",
	"Star",
	"Leaf",
	"Milk",
	"Door",
	"Ship",
	"Cake",
	"Bird",
	"Rock",
	"Band",
	"Ring",
	"Frog",
	"Lion",
	"King",
	"Dust",
	"Rice",
	"Boot",
	"Farm",
	"Apple",
	"Bread",
	"Chair",
	"Dance",
	"Earth",
	"Field",
	"Grape",
	"House",
	"Lemon",
	"Music",
	"Night",
	"Olive",
	"Party",
	"Quiet",
	"River",
	"Stone",
	"Table",
	"Truck",
	"Water",
	"Zebra",
	"Beach",
	"Clock",
	"Flour",
	"Grass",
	"Happy"
]

func get_prompt() -> String:
	var word_index = randi() % words.size()
	
	var word = words[word_index]
	
	var actual_word = word.substr(0, 1).to_lower() + word.substr(1).to_lower()
	
	
	return actual_word
