extends Control

onready var Click_sound = get_node("/root/ClickSound")

func _on_Stage1_pressed():
	Click_sound.play()
	get_tree().change_scene("res://Intro.tscn")


func _on_Stage2_pressed():
	Click_sound.play()
	get_tree().change_scene("res://Stage2.tscn")

func _on_Stage3_pressed():
	Click_sound.play()
	pass # Replace with function body.

func _on_Synonym_pressed():
	Click_sound.play()
	get_tree().change_scene("res://Infinite.tscn")


func _on_Back_pressed():
	Click_sound.play()
	get_tree().change_scene("res://MainMenu.tscn")
