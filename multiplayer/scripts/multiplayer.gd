extends Node3D


var peer = ENetMultiplayerPeer.new()
@onready var player_scene = load("res://multiplayer/multiplayer_character.tscn")

@onready var menu = $MultiplayerMenu
@onready var player_ui = $PlayerUI

func _ready():
	player_ui.hide()

func _on_host_pressed():
	print('multiplayer.gd')
	print('host world')
	peer.create_server(139)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	menu.hide()
	player_ui.show()

func _on_join_pressed():
	print('join world')
	peer.create_client( "25.6.37.145", 139 )
	multiplayer.multiplayer_peer = peer
	menu.hide()
	player_ui.show()

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func del_player(id):
	rpc('_del_player',id)
