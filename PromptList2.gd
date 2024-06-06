extends Node

var words = [
	"Angel",
	"Beach",
	"Candy",
	"Dwarf",
	"Eagle",
	"Fruit",
	"Globe",
	"Honey",
	"Image",
	"Jelly",
	"Knife",
	"Light",
	"Mango",
	"Niece",
	"Onion",
	"Peach",
	"Queen",
	"Rainy",
	"Sauce",
	"Tiger",
	"Uncle",
	"Vivid",
	"Woven",
	"Xerus",
	"Youth",
	"Animal",
	"Basket",
	"Carpet",
	"Desert",
	"Friend",
	"Garden",
	"Hunter",
	"Island",
	"Kitten",
	"Lizard",
	"Monkey",
	"Nectar",
	"Orange",
	"Planet",
	"Rabbit",
	"Secret",
	"Tomato",
	"Unicorn",
	"Velvet",
	"Window",
	"Yellow",
	"Zipper",
	"Bamboo",
	"Canyon",
	"Dollar"
]

func get_prompt() -> String:
	var word_index = randi() % words.size()
	
	var word = words[word_index]
	
	var actual_word = word.substr(0, 1).to_lower() + word.substr(1).to_lower()
	
	
	return actual_word
