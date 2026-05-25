extends RigidBody2D

func _ready():

	await get_tree().create_timer(5.0).timeout

	queue_free()

func _on_body_entered(body):

	if body.is_in_group("player"):

		if body.has_method("take_damage"):

			body.take_damage(1)

	queue_free()


func _on_area_2d_body_entered(body):

	if body.is_in_group("player"):

		if body.has_method("take_damage"):

			body.take_damage(1)

	queue_free()
