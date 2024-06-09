extends KinematicBody2D

onready var animated_sprite = $AnimatedSprite
onready var death_sound = $bossdeath_sound

export (float) var speed = 100
var target_position = Vector2(300, 200)

func _physics_process(delta: float) -> void:
	animated_sprite.play("boss_idle")
	var direction = (target_position - global_position).normalized()
	global_position += direction * speed * delta

	if global_position.distance_to(target_position) < speed * delta:
		
		global_position = target_position

func play_death_animation():
	animated_sprite.play("death")
	death_sound.play()
