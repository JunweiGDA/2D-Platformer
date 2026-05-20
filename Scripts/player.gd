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
@export var health : float = 3

var jump_count : int = 0
var move_input : float


var held_rock = null
var facing_direction := Vector2.RIGHT

var stunned := false
var is_game_over := false
var can_die := false

@onready var sprite : Sprite2D = $Sprite
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var audio : AudioStreamPlayer = $AudioStreamPlayer

var take_damage_sfx : AudioStream = preload("res://Audio/take_damage.wav")
var coin_sfx : AudioStream = preload("res://Audio/coin.wav")


func _ready():
	print("PLAYER SPAWNED")


	await get_tree().create_timer(0.3).timeout
	can_die = true


func _physics_process(delta):


	if not is_on_floor():
		velocity.y += gravity * delta

	if stunned:
		move_and_slide()
		return

	move_input = Input.get_axis("move_left", "move_right")

	if move_input != 0:
		facing_direction = Vector2.RIGHT if move_input > 0 else Vector2.LEFT

	if move_input != 0:
		velocity.x = lerp(velocity.x, move_input * move_speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, braking * delta)

	if Input.is_action_just_pressed("jump"):

		if is_on_floor():
			velocity.y = -jump_force
			jump_count = 1

		elif jump_count < max_jumps:
			if PlayerStats.score >= double_jump_cost:

				PlayerStats.score -= double_jump_cost
				OnUpdateScore.emit(PlayerStats.score)

				velocity.y = -jump_force
				jump_count += 1

	if is_on_floor():
		jump_count = 0



	if global_position.y > 5000:
		game_over()

	move_and_slide()

func game_over():

	print("GAME OVER")

	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
func _process(delta):

	if held_rock:

		var dir = 1 if facing_direction == Vector2.RIGHT else -1

		held_rock.global_position = global_position + Vector2(16 * dir, -10)

	if Input.is_action_just_pressed("pick_up"):

		var rock = get_nearby_rock()

		if rock:

			pick_up_rock(rock)

			print("PICKED UP ROCK")

	if Input.is_action_just_pressed("throw"):

		if held_rock:

			throw_rock()

func get_nearby_rock():

	var bodies = $PickupArea.get_overlapping_bodies()

	print(bodies)

	for body in bodies:

		print(body.name)

		print(body.get_groups())

		if body.is_in_group("rocks"):

			print("FOUND ROCK")

			return body

	return null

func pick_up_rock(rock):

	held_rock = rock

	rock.freeze = true

	rock.linear_velocity = Vector2.ZERO

	rock.angular_velocity = 0


	rock.set_collision_layer(0)
	rock.set_collision_mask(0)

	rock.global_position = global_position + Vector2(12, -10)


func throw_rock():

	if held_rock == null:
		return

	var rock = held_rock

	held_rock = null

	rock.freeze = false


	rock.set_collision_layer(8)
	rock.set_collision_mask(3)

	var dir = 1 if facing_direction == Vector2.RIGHT else -1

	rock.global_position = global_position + Vector2(20 * dir, -10)

	rock.linear_velocity = Vector2(450 * dir, -150)

func increase_score(amount : int):

	PlayerStats.score += amount

	OnUpdateScore.emit(PlayerStats.score)

	play_sound(coin_sfx)

	print("COIN PICKED")



func take_damage(amount : float):

	health -= amount

	OnUpdateHealth.emit(int(health))

	play_sound(take_damage_sfx)


	if velocity.x >= 0:
		velocity.x = -150
	else:
		velocity.x = 150

	print("PLAYER HIT")

	if health <= 0:
		game_over()



func play_sound(sound : AudioStream):

	audio.stream = sound
	audio.play()
