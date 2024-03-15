extends Control

@onready var character = $"../.."

func _on_resume_pressed():
	character.pause_game()

func _on_exit_pressed():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	get_tree().change_scene_to_file("res://common/main_menu.tscn")
