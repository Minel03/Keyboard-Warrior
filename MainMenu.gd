extends Control




func _on_StartButton_pressed():
	get_tree().change_scene("res://StageMenu.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
