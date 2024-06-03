extends Control

var settings_scene = preload("res://Settings.tscn")
onready var Click_sound = get_node("/root/ClickSound")

func _on_ResumeButton_pressed():
	Click_sound.play()
	queue_free()
	get_tree().paused = false

func _on_SettingsButton_pressed():
	var settings_instance = settings_scene.instance()
	add_child(settings_instance)

func _on_MainMenuButton_pressed():
	Click_sound.play()
	get_tree().paused = false
	get_tree().change_scene("res://MainMenu.tscn")
	
