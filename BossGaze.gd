extends CharacterBody2D

@export var max_health := 5
@export var eye_bullet_scene : PackedScene
@export var player : Node2D
@export var phase2_scene : PackedScene
@onready var boss_text = $"../CanvasLayer/BossText"

var health := 0

# Boss phases
var phase := 1

# Bullet speed
var bullet_speed := 180

func _ready():

	health = max_health

	print("Boss HP:", health)

	attack_loop()

	phase_loop()

# =========================
# PHASE SYSTEM
# =========================

func phase_loop():

	# Weak for first 17 seconds
	await get_tree().create_timer(17.0).timeout

	phase = 1

	bullet_speed = 260

	print("Boss stronger!")

	# Much stronger after 20 seconds
	await get_tree().create_timer(10.0).timeout

	phase = 2

	bullet_speed = 380

	print("Boss enraged!")

# =========================
# ATTACK LOOP
# =========================

func attack_loop():

	while true:

		await get_tree().create_timer(20).timeout

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

	# Phase 1 = single bullet
	if phase == 1:

		spawn_bullet(base_dir)

	# Phase 2 = double bullet
	elif phase == 2:

		spawn_bullet(base_dir.rotated(-0.1))
		spawn_bullet(base_dir.rotated(0.1))

	# Phase 3 = triple bullet
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

func take_damage(amount: int):

	health -= amount

	print("Boss HP:", health)

	if health <= 0:
		die()

# =========================
# DEATH
# =========================

func die():

	print("TRANSFORMING...")

	# =========================
	# HEAL PLAYER
	# =========================

	if player != null:

		player.health = 3

		player.OnUpdateHealth.emit(
			int(player.health)
		)

		print("Player healed!")

	# Small delay
	await get_tree().create_timer(1.0).timeout

	# =========================
	# SPAWN PHASE 2
	# =========================

	if phase2_scene != null:

		var phase2 = phase2_scene.instantiate()

		get_tree().current_scene.add_child(phase2)

		phase2.global_position = global_position

	queue_free()
