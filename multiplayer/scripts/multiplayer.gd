extends Node3D


var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
@onready var player_scene = load("res://multiplayer/multiplayer_character.tscn")
@onready var ip_input = $MultiplayerMenu/VBoxContainer/HBoxContainer/IPInput
@onready var port_input = $MultiplayerMenu/VBoxContainer/HBoxContainer/PortInput
@onready var menu = $MultiplayerMenu
@onready var player_ui = $PlayerUI

var timed: int
var connected = false
var retry = 0

func _ready():
	player_ui.hide()
	timed = Time.get_ticks_msec()

func _process(delta):

	var stat = peer.get_connection_status()

	if stat == 0:
		timed = Time.get_ticks_msec()

	if stat == 1:
		if (Time.get_ticks_msec() - timed) > 2000:
			retry += 1
			print('Connecting...')
			timed = Time.get_ticks_msec()

	if stat == 2 and not connected:
		retry = 0
		connected = true
		print('Connected')
		timed = Time.get_ticks_msec()
		player_ui.show()

	if retry == 3:
		print('Connection Timed Out...')
		peer.close()
		retry = 0
		menu.show()

func _on_host_pressed():
	print('multiplayer.gd')
	print('host world')
	if not _handle_input():
		return
	peer.set_bind_ip(ip_input.text)
	peer.create_server(int(port_input.text))
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_del_player)
	_add_player()
	menu.hide()
	player_ui.show()

func _on_join_pressed():
	print('join world')
	if not _handle_input():
		return
	peer.create_client( ip_input.text, int(port_input.text) )
	print(peer.get_connection_status())
	multiplayer.multiplayer_peer = peer
	menu.hide()

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://common/main_menu.tscn")

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func _del_player( id ):
	var player = get_node_or_null(str(id))
	if player:
		player.queue_free()
	#rpc('_del_player',id)

func _handle_input():
	print(ip_input.text)
	if not ip_input.text:
		print('Invalid IP!')
		return false

	print(int(port_input.text))
	if not port_input.text:
		print('Invalid Port!')
		return false

	return true
