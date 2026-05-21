extends Area2D

func _ready():
	print("DEATHZONE READY")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("DEATHZONE HIT:", body.name)
