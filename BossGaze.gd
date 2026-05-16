extends CharacterBody2D

@export var player_path : NodePath
@onready var player = get_tree().get_first_node_in_group("player")


func _ready():

	player = get_node(player_path)

func _process(delta):

	if player == null:
		return


	var distance = global_position.distance_to(player.global_position)


	if distance < 200:

		print("EYE DAMAGE")

		player.take_damage(0.3 * delta)


func _on_area_2d_body_entered(body):

	print("TOUCH:", body.name)

	if body.has_method("take_damage"):

		body.take_damage(1)
