extends Area2D

@export var coins_reward := 5
var used := false

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if used:
		return
	
	if not body.has_method("take_damage"):
		return

	used = true  # 💡 prevents reuse immediately

	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var roll = rng.randi_range(1, 100)

	if roll <= 5:
		# 💀 5% death
		body.take_damage(999)
	else:
		# 💰 95% reward
		if body.has_method("increase_score"):
			body.increase_score(coins_reward)

	# 🧹 remove block after interaction
	queue_free()
