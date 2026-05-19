extends CharacterBody2D

signal OnUpdateHealth(health : int)
signal OnUpdateScore(score : int)

@export var move_speed : float = 100
@export var acceleration : float = 50
@export var braking : float = 20
@export var gravity : float = 500
@export var jump_force : float = 200
@export var max_jumps : int = 2
@export var double_jump_cost : int = 3

var jump_count : int = 0
@export var health : float = 3

var move_input : float

# =========================
# ROCK SYSTEM (AUTO PICKUP)
# =========================
var held_rock = null

var facing_direction := Vector2.RIGHT
var stunned := false
var is_game_over := false

@onready var sprite : Sprite2D = $Sprite
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var audio : AudioStreamPlayer = $AudioStreamPlayer
@onready var double_jump_ui : Label = get_tree().current_scene.get_node("CanvasLayer/DoubleJumpUI")

var take_damage_sfx : AudioStream = preload("res://Audio/take_damage.wav")
var coin_sfx : AudioStream = preload("res://Audio/coin.wav")


# =========================
# PHYSICS
# =========================
func _physics_process(delta):

	if not is_on_floor():
		velocity.y += gravity * delta

	if stunned:
		move_and_slide()
		return

	move_input = Input.get_axis("move_left", "move_right")

	if move_input > 0:
		facing_direction = Vector2.RIGHT
	elif move_input < 0:
		facing_direction = Vector2.LEFT

	if move_input != 0:
		velocity.x = lerp(velocity.x, move_input * move_speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, braking * delta)

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

	if is_on_floor():
		jump_count = 0

	move_and_slide()


# =========================
# PROCESS
# =========================
func _process(_delta):

	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

	if global_position.y > 200:
		game_over()

	_manage_animation()

	sprite.modulate = Color.WHITE

	# =========================
	# AUTO PICKUP (NEW)
	# =========================
	if held_rock == null:
		var rock = get_nearby_rock()
		if rock:
			pick_up_rock(rock)

	# =========================
	# THROW
	# =========================
	if Input.is_action_just_pressed("throw"):
		if held_rock:
			throw_rock()


# =========================
# FIND ROCK
# =========================
func get_nearby_rock():

	for body in $PickupArea.get_overlapping_bodies():
		if body.is_in_group("rocks"):
			return body

	return null


# =========================
# PICKUP
# =========================
func pick_up_rock(rock):

	held_rock = rock

	held_rock.freeze = true
	held_rock.linear_velocity = Vector2.ZERO

	held_rock.reparent(self)
	held_rock.position = Vector2(12, -10)


# =========================
# THROW
# =========================
func throw_rock():

	var rock = held_rock
	held_rock = null

	rock.reparent(get_tree().current_scene)

	var dir = -1 if sprite.flip_h else 1

	rock.global_position = global_position + Vector2(20 * dir, -10)

	rock.freeze = false
	rock.linear_velocity = Vector2(350 * dir, -120)


# =========================
# ANIMATION
# =========================
func _manage_animation():

	if stunned:
		anim.play("RESET")
		return

	if not is_on_floor():
		anim.play("jump")
	elif velocity.x != 0:
		anim.play("move")
	else:
		anim.play("RESET")


# =========================
# DAMAGE SYSTEM
# =========================
func take_damage(amount : float):

	health -= amount
	OnUpdateHealth.emit(int(health))

	play_sound(take_damage_sfx)

	if health <= 0:
		call_deferred("game_over")


func game_over():

	if is_game_over:
		return

	is_game_over = true
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/menu.tscn")


func increase_score(amount : int):

	PlayerStats.score += amount
	OnUpdateScore.emit(PlayerStats.score)
	play_sound(coin_sfx)


func play_sound(sound : AudioStream):

	audio.stream = sound
	audio.play()
