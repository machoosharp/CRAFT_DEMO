extends Control

func _on_chop_log_pressed():
	print('log chop')
	get_tree().change_scene_to_file("res://chop_log/main.tscn")

func _on_mesh_proc_pressed():
	print('mesh world')
	get_tree().change_scene_to_file("res://mesh_world/procedural_world.tscn")

func _on_block_proc_pressed():
	print('block world')
	get_tree().change_scene_to_file("res://minecraft_clone/minecraft_clone.tscn")

func _on_multiplayer_pressed():
	print('multiplayer world')
	get_tree().change_scene_to_file("res://multiplayer/multiplayer.tscn")

func _on_exit_pressed():
	get_tree().quit()
