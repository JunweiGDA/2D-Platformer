extends Area2D

@export var speed := 50
@export var damage := 1
@export var health := 2

var player = null


func _physics_process(_delta):
	pass


func _on_detect_area_body_entered(body):

	if body.is_in_group("player"):

		player = body

		player.take_damage(damage)


func _on_detect_area_body_exited(body):

	if body.is_in_group("player"):

		player = null


func take_damage(amount):

	health -= amount

	print("Dummy HP:", health)

	if health <= 0:

		queue_free()
