extends Node

#List from here https://www.dictionary.com/learn/word-lists/general/H23wqeCDqyg
var words = [
	"Canary", 
	"Postgraduate",
	"Anadramous",
	"Heehaw",
	"Subsolar",
	"Sortie",
	"Nursemaid",
	"Inceptive",
	"Consecrate",
	"Apterygial",
	"Encyclopedism",
	"Insignia",
	"Lobar",
	"Tonguing",
	"Ferroelectic",
	"Mariculture",
	"Chatty",
	"Deify",
	"Optical",
	"Trickery",
	"Culture",
	"Limit",
	"Enrichment",
	"Cytotoxic",
	"Radio",
	"Misadvise",
	"Derivation",
	"Medievalism",
	"Gravitate",
	"Carillon",
	"Drew",
	"Opposite",
	"Shuck",
	"Eradicate",
	"Legging",
	"Belong",
	"Turbofan",
	"Frost",
	"Metaphase",
	"Yad",
	"Trademark"
]

func get_prompt() -> String:
	var word_index = randi() % words.size()
	
	var word = words[word_index]
	
	var actual_word = word.substr(0, 1).to_upper() + word.substr(1).to_lower()
	
	
	return actual_word
