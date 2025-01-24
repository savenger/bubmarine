extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

var ip_adress :String

func get_local_ip() -> String:
	for address in IP.get_local_addresses():
		if "." in address and not address.begins_with("127.") and not address.begins_with("169.254."):
			if address.begins_with("192.168.") or address.begins_with("10.") or (address.begins_with("172.") and int(address.split(".")[1]) >= 16 and int(address.split(".")[1]) <= 31):
				return address
	return "unknown"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$lblIP.text = "Local IP address: " + get_local_ip()
	print_debug(get_local_ip())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_btn_host_pressed() -> void:
	peer.create_server(1234)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()

func _on_btn_join_pressed() -> void:
	peer.create_client($txtJoin.text, 1234)
	multiplayer.multiplayer_peer = peer

func _add_player(id = 1) -> void:
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
