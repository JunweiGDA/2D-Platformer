extends CharacterBody2D

@export var speed := 20
@export var attack_range := 40
@export var damage := 1

var player = null
var can_attack := true


func _physics_process(delta):

	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = (player.global_position - global_position).normalized()

	velocity = direction * speed

	move_and_slide()

	var distance = global_position.distance_to(player.global_position)

	if distance <= attack_range and can_attack:
		attack()


func attack():

	can_attack = false

	print("DUMMY ATTACK")

	if player != null:
		player.take_damage(damage)

	$Timer.start()


func _on_detect_area_body_entered(body):

	player = body


func _on_detect_area_body_exited(body):

	player = null


func _on_timer_timeout():

	can_attack = true
