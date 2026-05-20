extends Node2D

@export var rock_scene: PackedScene
@export var player: Node2D

var rng = RandomNumberGenerator.new()

func _ready():

	rng.randomize()

	var timer = Timer.new()
	timer.wait_time = 5
	timer.autostart = true
	timer.one_shot = false

	timer.timeout.connect(spawn_rock)

	add_child(timer)

func spawn_rock():

	if rock_scene == null:
		print("Rock scene missing")
		return

	if player == null:
		print("Player missing")
		return

	var rock = rock_scene.instantiate()

	# random offset near player
	var offset = Vector2(
		rng.randi_range(-300, 300),
		rng.randi_range(-100, 100)
	)

	# IMPORTANT
	rock.global_position = player.global_position + offset

	# Add into current scene
	get_tree().current_scene.add_child(rock)

	print("Rock spawned")
