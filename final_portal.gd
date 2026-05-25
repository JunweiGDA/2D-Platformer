extends Area2D

func _on_body_entered(body):

	if body.is_in_group("player"):

		print("FINAL PORTAL!")

		get_tree().change_scene_to_file(
			"res://win_menu.tscn"
			
		)
