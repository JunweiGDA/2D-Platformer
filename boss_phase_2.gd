extends CharacterBody2D

@export var max_health := 3
@onready var laugh_audio = $LaughAudio
@onready var voice_audio = $VoiceAudio
@export var portal_scene : PackedScene
@onready var boss_text = get_tree().current_scene.get_node("CanvasLayer/BossText")
var missed_final_attack := false
var health := 0
var player = null

var attacking := false

func _ready():

	randomize()

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
	# THIRD ATTACK (MISS)
	# =========================

	await get_tree().create_timer(20.0).timeout

	if player:

		knife_attack()

	# =========================
	# FINAL HUNT
	# FAST ATTACKS FOREVER
	# =========================

	while true:

		await get_tree().create_timer(10.0).timeout

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

	# =========================
	# CHECK DISTANCE
	# =========================

	if global_position.distance_to(player.global_position) < 80:

		print("ATTACK!")

		# PLAYER HAS 1 HP
		if player.health <= 1:

			# FIRST TIME = MISS
			if not missed_final_attack:

				missed_final_attack = true

				print("MISS...")
				print("BOSS PLAYING WITH PLAYER")

				boss_text.text = "HAHA... YOU'RE SO LUCKY...\nNEXT TIME... HEHEHE... NO LUCK FOR YOU..."
				boss_text.visible = true

				await get_tree().create_timer(3.0).timeout

				boss_text.visible = false

			# NEXT TIME = GUARANTEED HIT
			else:

				print("FINAL EXECUTION!")

				player.take_damage(1)

		# NORMAL HIT
		else:

			player.take_damage(1)

	else:

		print("PLAYER ESCAPED!")

	# RELEASE PLAYER
	player.stunned = false

	print("PLAYER FREE")

	attacking = false
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

	# SPAWN PORTAL
	if portal_scene != null:

		var portal = portal_scene.instantiate()

		get_tree().current_scene.add_child(portal)

		portal.global_position = global_position

	queue_free()
