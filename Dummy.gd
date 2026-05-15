extends CharacterBody2D

var player = null

var speed = 50
var attack_range = 40
var damage = 1

var can_attack = true

func _physics_process(delta):

	if player != null:

		# Follow player
		var direction = (player.global_position - global_position).normalized()

		velocity = direction * speed

		move_and_slide()

		# Distance check
		var distance = global_position.distance_to(player.global_position)

		if distance <= attack_range and can_attack:
			attack()

func attack():

	can_attack = false

	print("Dummy attacks!")

	if player != null:
		player.take_damage(damage)

	$Timer.start()

func _on_timer_timeout():

	can_attack = true

func _on_area_2d_body_entered(body):

	if body.name == "Player":
		player = body

func _on_area_2d_body_exited(body):

	if body.name == "Player":
		player = null
