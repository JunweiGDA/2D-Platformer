extends CharacterBody2D

@export var max_health := 3
@onready var laugh_audio = $LaughAudio
@onready var voice_audio = $VoiceAudio
var health := 0
var player = null

var attacking := false

func _ready():

	health = max_health

	player = get_tree().get_first_node_in_group("player")

	print("PHASE 2 START!")

	skill_loop()

# =========================
# SKILL LOOP
# =========================

func skill_loop():

	# =========================
	# FIRST ATTACK
	# =========================

	await get_tree().create_timer(10.0).timeout

	if player:

		knife_attack()

	# =========================
	# SECOND ATTACK
	# =========================

	await get_tree().create_timer(15.0).timeout

	if player:

		knife_attack()

	# =========================
	# FINAL ATTACK
	# =========================

	await get_tree().create_timer(20.0).timeout

	if player:

		knife_attack()

func knife_attack():

	if attacking:
		return

	attacking = true

	print("BOSS TELEPORT!")
	laugh_audio.play()
	# TELEPORT NEXT TO PLAYER
	global_position = player.global_position + Vector2(-40, 0)
	voice_audio.play()
	# FREEZE PLAYER
	player.stunned = true

	# STOP PLAYER MOVEMENT
	player.velocity = Vector2.ZERO

	print("PLAYER FROZEN")

	# KNIFE RAISE
	print("RAISING KNIFE...")

	await get_tree().create_timer(3.0).timeout

	# CHECK DISTANCE
	if global_position.distance_to(player.global_position) < 80:

		print("PLAYER HIT!")

		player.take_damage(1)

	else:

		print("PLAYER ESCAPED!")

	# RELEASE PLAYER
	player.stunned = false

	print("PLAYER FREE")

	attacking = false

# =========================
# DAMAGE
# =========================

func take_damage(amount):

	health -= amount

	print("PHASE 2 HP:", health)

	if health <= 0:

		die()

# =========================
# DEATH
# =========================

func die():

	print("BOSS FINAL DEATH")

	queue_free()
