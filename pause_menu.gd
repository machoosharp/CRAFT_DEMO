extends Control

@onready var character = $"../.."

func _on_resume_pressed():
	character.pause_game()

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
