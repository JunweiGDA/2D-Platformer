extends RigidBody2D

@onready var hitbox: Area2D = $Hitbox

func _ready():
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _on_hitbox_body_entered(body):

	if body.is_in_group("boss"):

		if body.has_method("take_damage"):
			body.take_damage(1)

		queue_free()
