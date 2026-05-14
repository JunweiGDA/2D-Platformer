extends Area2D

@export var coins_reward := 10

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.has_method("take_damage"):
		return

	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var result = rng.randi_range(0, 1)  # 0 or 1

	if result == 0:
		# 💀 Kill player
		body.take_damage(999)
	else:
		# 💰 Give coins
		if body.has_method("increase_score"):
			body.increase_score(coins_reward)
