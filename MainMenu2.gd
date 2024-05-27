extends Control

var settings_scene = preload("res://Settings.tscn")

func _on_StartButton_pressed():
	get_tree().change_scene("res://DifficultySelection.tscn")

func _on_SettingsButton_pressed():
	var settings_instance = settings_scene.instance()
	add_child(settings_instance)
	print("settings popup")

func _on_CloseButton_pressed():
	get_tree().quit()
