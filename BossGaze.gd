extends CharacterBody2D

@export var max_health := 5
@export var eye_bullet_scene : PackedScene
@export var player : Node2D
@export var phase2_scene : PackedScene

@onready var boss_text = get_tree().current_scene.get_node("CanvasLayer/BossText")
@onready var dark_screen = %DarkScreen

var health := 0

# Boss phases
var phase := 1

# Bullet speed
var bullet_speed := 180

# =========================
# READY
# =========================

func _ready():

	health = max_health

	# START WITH NORMAL SCREEN
	dark_screen.color.a = 0

	# HIDE TEXT
	boss_text.visible = false

	print("Boss HP:", health)

	attack_loop()

	phase_loop()

# =========================
# PHASE SYSTEM
# =========================

func phase_loop():

	# Stronger after 17 sec
	await get_tree().create_timer(17.0).timeout

	phase = 1
	bullet_speed = 260

	print("Boss stronger!")

	# Enraged after 10 sec
	await get_tree().create_timer(10.0).timeout

	phase = 2
	bullet_speed = 380

	print("Boss enraged!")

# =========================
# ATTACK LOOP
# =========================

func attack_loop():

	while true:

		await get_tree().create_timer(20.0).timeout

		shoot_eye()

# =========================
# SHOOT EYE
# =========================

func shoot_eye():

	if eye_bullet_scene == null:
		return

	if player == null:
		return

	var base_dir = (
		player.global_position - global_position
	).normalized()

	# Phase 1
	if phase == 1:

		spawn_bullet(base_dir)

	# Phase 2
	elif phase == 2:

		spawn_bullet(base_dir.rotated(-0.1))
		spawn_bullet(base_dir.rotated(0.1))

	# Phase 3
	else:

		spawn_bullet(base_dir.rotated(-0.2))
		spawn_bullet(base_dir)
		spawn_bullet(base_dir.rotated(0.2))

# =========================
# SPAWN BULLET
# =========================

func spawn_bullet(dir):

	var bullet = eye_bullet_scene.instantiate()

	get_tree().current_scene.add_child(bullet)

	bullet.global_position = global_position

	bullet.direction = dir

	bullet.speed = bullet_speed

# =========================
# DAMAGE
# =========================

func take_damage(amount : int):

	health -= amount

	print("Boss HP:", health)

	if health <= 0:

		die()

# =========================
# DEATH / TRANSFORMATION
# =========================

func die():

	print("TRANSFORMING...")

	# =========================
	# DIALOGUE
	# =========================

	boss_text.text = "I LIKE YOUR BLOOD..."
	boss_text.visible = true

	# =========================
	# DARK SCREEN
	# =========================

	dark_screen.color.a = 0.8

	# =========================
	# HEAL PLAYER
	# =========================

	if player != null:

		player.health = 3

		player.OnUpdateHealth.emit(
			int(player.health)
		)

		print("Player healed!")

	# =========================
	# WAIT
	# =========================

	await get_tree().create_timer(3.0).timeout

	# =========================
	# REMOVE EFFECTS
	# =========================

	dark_screen.color.a = 0

	boss_text.visible = false

	# =========================
	# SPAWN PHASE 2
	# =========================

	if phase2_scene != null:

		var phase2 = phase2_scene.instantiate()

		get_tree().current_scene.add_child(phase2)

		phase2.global_position = global_position

	queue_free()
