extends Node2D

@export var rock_scene : PackedScene
@export var player : Node2D

var rng = RandomNumberGenerator.new()

@export var max_rocks := 15

func _ready():

	rng.randomize()

	spawn_loop()

func spawn_loop():

	while true:

		await get_tree().create_timer(10000).timeout

		spawn_rock()

func spawn_rock():

	if rock_scene == null:
		return

	if player == null:
		return

	# Count rocks
	var rock_count := 0

	for rock in get_tree().get_nodes_in_group("rocks"):

		rock_count += 1

	# Stop if too many rocks
	if rock_count >= max_rocks:
		return

	var rock = rock_scene.instantiate()

	get_tree().current_scene.add_child(rock)

	# Spawn near player
	var offset = Vector2(
		rng.randi_range(-200, 200),
		-150
	)

	rock.global_position = player.global_position + offset
