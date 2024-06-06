extends Area2D

onready var projectile = $Sprite

export var speed: float = 600
var direction: Vector2 = Vector2.ZERO
var target: Node2D = null
var is_target_valid: bool = true  # Track if the target is still valid

func _process(delta: float) -> void:
	if target and is_target_valid:
		direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
	else:
		queue_free()  # Remove the projectile if there's no target or if the target is invalid

func set_target(new_target: Node2D) -> void:
	target = new_target

func set_is_target_valid(valid: bool) -> void:
	is_target_valid = valid

func _on_Projectile_body_entered(body):
	if body == target:
		body.play_death_animation()
		projectile.hide()
		var delay_timer = Timer.new()
		delay_timer.wait_time = 0.1  # Adjust the delay time as needed
		add_child(delay_timer)
		delay_timer.start()
		delay_timer.connect("timeout", self, "_on_delay_timer_timeout")

func _on_delay_timer_timeout():
	queue_free()  # Remove the projectile
	if target:
		target.queue_free()  # Remove the target after the delay
