extends CharacterBody2D

signal OnUpdateHealth(health : int)
signal OnUpdateScore(score : int)

@export var move_speed : float = 100
@export var acceleration : float = 50
@export var braking : float = 20
@export var gravity : float = 500
@export var jump_force : float = 200
@export var max_jumps : int = 2
@export var double_jump_cost : int = 5

var jump_count : int = 0

# Changed to float for gaze damage over time
@export var health : float = 3

var move_input : float

# =========================
# GAZE SYSTEM
# =========================
var facing_direction := Vector2.RIGHT

var fear := 0.0
var max_fear := 100.0

var stunned := false

# =========================

@onready var sprite : Sprite2D = $Sprite
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var audio : AudioStreamPlayer = $AudioStreamPlayer

@onready var double_jump_ui : Label = get_tree().current_scene.get_node("CanvasLayer/DoubleJumpUI")

var take_damage_sfx : AudioStream = preload("res://Audio/take_damage.wav")
var coin_sfx : AudioStream = preload("res://Audio/coin.wav")

var is_game_over := false

func _physics_process(delta):

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# =========================
	# STUN CHECK
	# =========================
	if stunned:
		move_and_slide()
		return

	# =========================
	# MOVEMENT INPUT
	# =========================
	move_input = Input.get_axis("move_left", "move_right")

	# Facing direction for boss gaze
	if move_input > 0:
		facing_direction = Vector2.RIGHT
	elif move_input < 0:
		facing_direction = Vector2.LEFT

	# Horizontal movement
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
	if Input.is_action_just_pressed("jump"):

		if is_on_floor():
			velocity.y = -jump_force
			jump_count = 1

		else:
			if jump_count < max_jumps:

				if PlayerStats.score >= double_jump_cost:

					PlayerStats.score -= double_jump_cost
					OnUpdateScore.emit(PlayerStats.score)

					velocity.y = -jump_force
					jump_count += 1

	# Reset jumps
	if is_on_floor():
		jump_count = 0

	move_and_slide()

func _process(_delta):

	# Flip sprite
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

	# Death by falling
	if global_position.y > 200:
		game_over()

	_manage_animation()

	# =========================
	# FEAR VISUAL EFFECT
	# =========================
	sprite.modulate = Color.WHITE.lerp(
		Color.RED,
		fear / max_fear
	)

	# =========================
	# DOUBLE JUMP UI
	# =========================
	if double_jump_ui != null:

		if PlayerStats.score >= double_jump_cost:
			double_jump_ui.text = "Double Jump: 5 coins (READY)"
			double_jump_ui.modulate = Color.GREEN

		else:
			double_jump_ui.text = "Double Jump: 5 coins (LOCKED)"
			double_jump_ui.modulate = Color.RED

func _manage_animation():

	if stunned:
		anim.play("idle")
		return

	if not is_on_floor():
		anim.play("jump")

	elif move_input != 0:
		anim.play("move")

	else:
		anim.play("idle")

# =========================
# DAMAGE
# =========================
func take_damage(amount : float):

	health -= amount

	OnUpdateHealth.emit(int(health))

	_damage_flash()

	play_sound(take_damage_sfx)

	if health <= 0:
		call_deferred("game_over")

# =========================
# STUN FUNCTION
# =========================
func stun(duration : float):

	if stunned:
		return

	stunned = true

	# Stop movement
	velocity.x = 0

	# Visual effect
	sprite.modulate = Color.DARK_RED

	print("PLAYER STUNNED")

	await get_tree().create_timer(duration).timeout

	stunned = false

	print("PLAYER RECOVERED")

# =========================
# GAME OVER
# =========================
func game_over():

	if is_game_over:
		return

	is_game_over = true

	var tree = get_tree()

	if tree:
		tree.call_deferred(
			"change_scene_to_file",
			"res://Scenes/menu.tscn"
		)

# =========================
# SCORE
# =========================
func increase_score(amount : int):

	PlayerStats.score += amount

	OnUpdateScore.emit(PlayerStats.score)

	play_sound(coin_sfx)

# =========================
# DAMAGE FLASH
# =========================
func _damage_flash():

	sprite.modulate = Color.RED

	await get_tree().create_timer(0.05).timeout

	# Restore fear tint
	sprite.modulate = Color.WHITE.lerp(
		Color.RED,
		fear / max_fear
	)

# =========================
# AUDIO
# =========================
func play_sound(sound : AudioStream):

	audio.stream = sound
	audio.play()

	if velocity.x < 0:
		$Sprite2D.flip_h = true
	elif velocity.x > 0:
		$Sprite2D.flip_h = false
