extends CharacterBody2D

@export var max_health := 1
var health := 0

func _ready():
	health = max_health
	print("Boss HP:", health)


# =========================
# DAMAGE
# =========================
func take_damage(amount: int):

	health -= amount
	print("Boss HP:", health)

	if health <= 0:
		die()


# =========================
# DEATH
# =========================
func die():
	print("Boss defeated!")
	queue_free()
