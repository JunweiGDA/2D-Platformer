extends Area2D

var rock_in_range = null

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):

	if body.is_in_group("rocks"):
		rock_in_range = body
		print("ROCK ENTERED:", body.name)

func _on_body_exited(body):

	if body == rock_in_range:
		rock_in_range = null
