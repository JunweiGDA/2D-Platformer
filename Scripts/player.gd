extends CharacterBody2D

@warning_ignore("unused_signal")
signal OnUpdateHealth(health : int)
signal OnUpdateScore(score : int)

# =========================
# PLAYER STATS
# =========================

@export var move_speed := 100.0
@export var acceleration := 50.0
@export var braking := 20.0
@export var gravity := 500.0
@export var jump_force := 200.0

@export var max_jumps := 2
@export var double_jump_cost := 3

@export var health := 3.0

var jump_count := 0
var move_input := 0.0

# =========================
# ROCK SYSTEM
# =========================

var held_rock = null
var facing_right := true
var can_pickup := true

# =========================
# STATE
# =========================

var stunned := false

# =========================
# NODES
# =========================

@onready var sprite : Sprite2D = $Sprite
@onready var anim : AnimationPlayer = $AnimationPlayer

@onready var audio : AudioStreamPlayer = $AudioStreamPlayer
@onready var heartbeat_audio : AudioStreamPlayer = $HeartbeatAudio
@onready var low_health_music : AudioStreamPlayer = $LowHealthMusic
# =========================
# AUDIO
# =========================

var take_damage_sfx = preload("res://Audio/take_damage.wav")
var coin_sfx = preload("res://Audio/coin.wav")

# =========================
# PHYSICS
# =========================

func _physics_process(delta):

	# =========================
	# STUNNED
	# =========================

	if stunned:

		velocity = Vector2.ZERO

		handle_animation()

		move_and_slide()

		return

	# =========================
	# NORMAL PLAYER
	# =========================

	handle_gravity(delta)

	handle_movement(delta)

	handle_jump()

	handle_animation()

	move_and_slide()

	check_game_over()

# =========================
# PROCESS
# =========================

func _process(_delta):

	handle_held_rock()

	handle_pickup()

	handle_throw()

# =========================
# MOVEMENT
# =========================

func handle_gravity(delta):

	if not is_on_floor():

		velocity.y += gravity * delta

	else:

		jump_count = 0

func handle_movement(delta):

	move_input = Input.get_axis(
		"move_left",
		"move_right"
	)

	# Flip player
	if move_input != 0:

		facing_right = move_input > 0

		sprite.flip_h = move_input < 0

	# Move
	if move_input != 0:

		velocity.x = lerp(
			velocity.x,
			move_input * move_speed,
			acceleration * delta
		)

	else:

		velocity.x = lerp(
			velocity.x,
			0.0,
			braking * delta
		)

# =========================
# JUMP
# =========================

func handle_jump():

	if not Input.is_action_just_pressed("jump"):
		return

	# First jump
	if is_on_floor():

		velocity.y = -jump_force

		jump_count = 1

		return

	# Double jump
	if jump_count < max_jumps:

		if PlayerStats.score >= double_jump_cost:

			PlayerStats.score -= double_jump_cost

			OnUpdateScore.emit(
				PlayerStats.score
			)

			velocity.y = -jump_force

			jump_count += 1

# =========================
# ROCK SYSTEM
# =========================

func handle_held_rock():

	if held_rock == null:
		return

	var dir = 1 if facing_right else -1

	held_rock.global_position = (
		global_position
		+ Vector2(16 * dir, -10)
	)

func handle_pickup():

	if not Input.is_action_just_pressed("pick_up"):
		return

	if not can_pickup:
		return

	var rock = get_nearby_rock()

	if rock:

		pick_up_rock(rock)

func handle_throw():

	if not Input.is_action_just_pressed("throw"):
		return

	if held_rock:

		throw_rock()

func get_nearby_rock():

	var bodies = $PickupArea.get_overlapping_bodies()

	for body in bodies:

		if body.is_in_group("rocks"):

			if body.can_pickup:

				return body

	return null

func pick_up_rock(rock):

	held_rock = rock

	rock.is_held = true

	rock.freeze = true

	rock.linear_velocity = Vector2.ZERO

	rock.angular_velocity = 0

func throw_rock():

	if held_rock == null:
		return

	var rock = held_rock

	held_rock = null

	rock.is_held = false

	rock.freeze = false

	rock.can_pickup = false

	rock.remove_from_group("rocks")

	var dir = 1 if facing_right else -1

	rock.global_position = (
		global_position
		+ Vector2(160 * dir, -60)
	)

	rock.linear_velocity = Vector2(
		530 * dir,
		-140
	)

# =========================
# DAMAGE
# =========================

func take_damage(amount : float):

	health -= amount

	OnUpdateHealth.emit(int(health))

	play_sound(take_damage_sfx)

	# =========================
	# LOW HP HORROR
	# =========================

	if health <= 1:

		# HEARTBEAT
		if not heartbeat_audio.playing:

			heartbeat_audio.play()

		# SAD PIANO
		if not low_health_music.playing:

			low_health_music.play()

	# =========================
	# KNOCKBACK
	# =========================

	if velocity.x >= 0:

		velocity.x = -150

	else:

		velocity.x = 150

	# =========================
	# DEATH
	# =========================

	if health <= 0:

		game_over()
# =========================
# SCORE
# =========================

func increase_score(amount : int):

	PlayerStats.score += amount

	OnUpdateScore.emit(PlayerStats.score)

	play_sound(coin_sfx)

# =========================
# SOUND
# =========================

func play_sound(sound):

	audio.stream = sound

	audio.play()

# =========================
# ANIMATION
# =========================

func handle_animation():

	if stunned:

		anim.play("RESET")

		return

	if not is_on_floor():

		anim.play("jump")

	elif move_input != 0:

		anim.play("move")

	else:

		anim.play("RESET")

# =========================
# GAME OVER
# =========================

func check_game_over():

	if global_position.y > 300:

		game_over()

func game_over():

	heartbeat_audio.stop()

	low_health_music.stop()

	GameManager.restart_level()
	if not is_on_floor():

		anim.play("jump")

	elif move_input != 0:

		anim.play("move")

	else:

		anim.play("RESET")
