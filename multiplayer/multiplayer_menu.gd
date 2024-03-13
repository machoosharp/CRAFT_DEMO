extends Control


var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene


func _on_host_pressed():
	print('host world')
	get_tree().change_scene_to_file("res://multiplayer/multiplayer.tscn")
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()

func _on_join_pressed():
	print('join world')
	peer.create_client("local_host", 135)
	multiplayer.multiplayer_peer = peer

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
