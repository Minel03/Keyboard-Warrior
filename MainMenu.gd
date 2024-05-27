extends Control

var settings_scene = preload("res://Settings.tscn")
onready var Click_sound = get_node("/root/ClickSound")

func _on_StartButton_pressed():
	Click_sound.play()
	get_tree().change_scene("res://StageMenu.tscn")

func _on_SettingsButton_pressed():
	Click_sound.play()
	var settings_instance = settings_scene.instance()
	add_child(settings_instance)
	print("settings popup")
	
func _on_QuitButton_pressed():
	Click_sound.play()
	get_tree().quit()
