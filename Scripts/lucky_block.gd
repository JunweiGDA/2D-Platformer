extends Area2D

@export var coins_reward := 3
var used := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if used:
		return

	if not body.is_in_group("player"):
		return

	used = true

	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var roll = rng.randi_range(1, 100)

	if roll <= 5:

		print("BAD LUCK")

		body.take_damage(999)

	else:

		print("GOOD LUCK")

		body.increase_score(coins_reward)

	queue_free()
