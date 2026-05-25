extends Node2D

func _ready():

	GameManager.set_level(
		"res://Scenes/level_3.tscn"
	)

	print("LEVEL 3 SAVED")
