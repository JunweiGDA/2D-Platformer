extends Node2D

var parallax : float = 0.7

var player = null


func _process(_delta):

	if player == null:

		player = get_tree().get_first_node_in_group("player")

		return

	global_position = player.global_position * parallax
