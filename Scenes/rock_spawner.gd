extends Node2D

@export var rock_scene : PackedScene
@export var player : Node2D

var rng = RandomNumberGenerator.new()

func _ready():

	rng.randomize()

	while true:

		await get_tree().create_timer(3.0).timeout

		spawn_rock()


func spawn_rock():

	if rock_scene == null:
		return

	if player == null:
		return

	var rock = rock_scene.instantiate()

	get_tree().current_scene.add_child(rock)

	# Spawn CLOSE to player
	var offset = Vector2(

		rng.randi_range(-120, 120),

		-120

	)

	rock.global_position = player.global_position + offset
