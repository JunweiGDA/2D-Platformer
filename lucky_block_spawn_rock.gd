extends Area2D

@export var rock_scene : PackedScene

var used := false

func _ready():

	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if used:
		return

	if not body.is_in_group("player"):
		return

	used = true

	spawn_rocks()

	queue_free()

# =========================
# SPAWN ROCKS
# =========================

func spawn_rocks():

	for i in range(1):

		var rock = rock_scene.instantiate()

		get_tree().current_scene.add_child(rock)

		rock.global_position = global_position + Vector2(
			randi_range(-60, 60),
			-40
		)

		# Small throw effect
		rock.linear_velocity = Vector2(
			randi_range(-120, 120),
			-150
		)
