extends Area2D

@export var next_level_path : String


func _ready():

	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	body.is_in_group("player")



	var _result = get_tree().change_scene_to_file(next_level_path)
