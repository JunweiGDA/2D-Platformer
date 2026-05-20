extends RigidBody2D

@onready var hitbox: Area2D = $Hitbox

var is_held := false

func _ready():
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(_delta):

	if is_held:
		freeze = true
		linear_velocity = Vector2.ZERO
		gravity_scale = 0
	else:
		freeze = false
		gravity_scale = 1


func _on_hitbox_body_entered(body):

	if is_held:
		return

	if body.is_in_group("boss"):
		if body.has_method("take_damage"):
			body.take_damage(1)

		queue_free()
