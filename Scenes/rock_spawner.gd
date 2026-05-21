extends Node2D

@export var rock_scene : PackedScene
@export var player : Node2D

var rng = RandomNumberGenerator.new()


func _ready():

	rng.randomize()

	spawn_loop()


func spawn_loop():

	while true:

		await get_tree().create_timer(3.0).timeout

		spawn_rock()


func spawn_rock():

	if rock_scene == null:
		return

	if player == null:
		return

	var rock = rock_scene.instantiate()

	var offset = Vector2(

		rng.randi_range(-150, 150),

		-200

	)

	rock.global_position = player.global_position + offset

	get_tree().current_scene.add_child(rock)
