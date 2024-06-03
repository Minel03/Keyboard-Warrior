extends KinematicBody2D

onready var animation = $AnimationPlayer
export (Color) var blue = Color("#4682b4")
export (Color) var green = Color("#639765")
export (Color) var red = Color("#a65455")

export (float) var speed = 1


func _physics_process(delta: float) -> void:
	global_position.y += speed
