extends Control

var settings_scene = preload("res://Settings.tscn")
onready var Click_sound = get_node("/root/ClickSound")

func _on_MainMenuButton_pressed():
	Click_sound.play()
	get_tree().paused = false
	get_tree().change_scene("res://MainMenu.tscn")

func _on_stage_2_pressed():
	Click_sound.play()
	get_tree().paused = false
	get_tree().change_scene("res://story/Chapter2_Intro.tscn")
