extends RigidBody2D

@onready var hitbox: Area2D = $Hitbox

var is_held := false
var can_pickup := true


func _ready():

	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(_delta):

	if is_held:

		freeze = true

		linear_velocity = Vector2.ZERO

		angular_velocity = 0

	else:

		freeze = false


func _on_hitbox_body_entered(body):

	if is_held:
		return

	if body.is_in_group("enemy") or body.is_in_group("boss"):

		if body.has_method("take_damage"):

			body.take_damage(1)

		call_deferred("queue_free")
