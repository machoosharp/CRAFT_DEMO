extends Control

@onready var char = $"../.."

func _on_resume_pressed():
	char.pause_game()

func _on_exit_pressed():
	get_tree().quit()
