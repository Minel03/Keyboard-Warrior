extends Control

onready var Click_sound = get_node("/root/ClickSound")

func _ready():
	MusicManager.play_menumusic()
	
func _on_Stage1_pressed():
	Click_sound.play()
	get_tree().change_scene("res://story/Chapter1_Intro.tscn")

func _on_Stage2_pressed():
	Click_sound.play()
	get_tree().change_scene("res://story/Chapter2_Intro.tscn")

func _on_Synonym_pressed():
	Click_sound.play()
	get_tree().change_scene("res://Infinite.tscn")

func _on_Back_pressed():
	Click_sound.play()
	get_tree().change_scene("res://MainMenu.tscn")
