extends CharacterBody2D

signal  OnUpdateHealth (health : int)
signal OnUpdateScore (score : int)

@export var move_speed: float = 100
@export var acceleration : float = 50
@export var braking : float = 20
@export var gravity : float = 500
@export var jump_force : float = 200
@export var max_jumps: int = 2
@export var double_jump_cost: int = 5

var jump_count: int = 0
@export var health : int = 3

var move_input : float 

@onready var sprite: Sprite2D = $Sprite
@onready var anim : AnimationPlayer =  $AnimationPlayer
@onready var audio : AudioStreamPlayer = $AudioStreamPlayer
@onready var double_jump_ui: Label = get_tree().current_scene.get_node("CanvasLayer/DoubleJumpUI")
var take_damage_sfx : AudioStream = preload("res://Audio/take_damage.wav")
var coin_sfx : AudioStream = preload("res://Audio/coin.wav")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	move_input = Input.get_axis("move_left", "move_right")

	if move_input != 0:
		velocity.x = lerp(velocity.x, move_input * move_speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, braking * delta)

	# JUMP MUST BE HERE
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





func _process(_delta): 
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0
	
	if global_position.y > 200:
		game_over()

	_manage_animation() 
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

	if global_position.y > 200:
		game_over()

	_manage_animation()

	# UI (MUST BE INSIDE FUNCTION)
	if double_jump_ui != null:
		if PlayerStats.score >= double_jump_cost:
			double_jump_ui.text = "Double Jump: 5 coins (READY)"
			double_jump_ui.modulate = Color.GREEN
		else:
			double_jump_ui.text = "Double Jump: 5 coins (LOCKED)"
			double_jump_ui.modulate = Color.RED
func _manage_animation():
	if not is_on_floor():
		anim.play("jump")
	elif move_input != 0: 
		anim.play("move")
	else:
		anim.play("idle")

func take_damage (amount : int):
	health -= amount
	OnUpdateHealth.emit(health)
	_damage_flash()
	play_sound(take_damage_sfx)
	
	if health <= 0:
		call_deferred("game_over")

var is_game_over := false

func game_over():
	if is_game_over:
		return

	is_game_over = true

	var tree = get_tree()
	if tree:
		tree.call_deferred("change_scene_to_file", "res://Scenes/menu.tscn")

func increase_score (_amount : int):
	PlayerStats.score += _amount
	OnUpdateScore.emit(PlayerStats.score)
	play_sound(coin_sfx)
	
func _damage_flash ():
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	sprite.modulate = Color.WHITE

func play_sound (sound : AudioStream):
	audio.stream = sound
	audio.play()
