extends KinematicBody2D

onready var animation = $AnimationPlayer
onready var death_animation = $DeathAnimation

export (float) var speed = 100
var target_position = Vector2(300, 200)

func _physics_process(delta: float) -> void:
	var direction = (target_position - global_position).normalized()
	global_position += direction * speed * delta

	if global_position.distance_to(target_position) < speed * delta:
		global_position = target_position

func play_death_animation():
	death_animation.play("death")
