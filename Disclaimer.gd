extends Control

func _ready():
	$AnimationPlayer.play("fadeinout")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
	get_tree().change_scene("res://MainMenu.tscn")
