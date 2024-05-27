extends Control

onready var Click_sound = get_node("/root/ClickSound")

func _on_BackButton_pressed():
	Click_sound.play()
	get_tree().change_scene("res://MainMenu.tscn")

func _on_diff1_pressed():
	Click_sound.play()
	get_tree().change_scene("res://Main.tscn")
