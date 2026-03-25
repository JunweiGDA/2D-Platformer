extends Node2D

var parallax : float = 0.7 
@onready var player = $"../Player"

func _process (_delta):
	global_position = player.golbal_position * parallax
