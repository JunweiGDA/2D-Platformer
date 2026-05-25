extends Node

var current_level := "res://Scenes/level_1.tscn"

# =========================
# SAVE LEVEL
# =========================

func set_level(level_path : String):

	current_level = level_path

# =========================
# RESTART LEVEL
# =========================

func restart_level():

	get_tree().change_scene_to_file(
		current_level
	)

# =========================
# GO TO MENU
# =========================

func go_to_menu():

	get_tree().change_scene_to_file(
		"res://Scenes/menu.tscn"
	)
