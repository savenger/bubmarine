extends Control

var peer = ENetMultiplayerPeer.new()
@export_file("*.tscn") var start_level = "res://Level/Level.tscn"
@export var ip_field: LineEdit

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
	multiplayer.peer_connected.connect(_say_hello)
	_say_hello()

func _on_btn_join_pressed() -> void:
	peer.create_client(ip_field.text, 1234)
	multiplayer.multiplayer_peer = peer

func _start_game() -> void:
	get_tree().change_scene_to_file(start_level)

func _say_hello() -> void:
	print("Hello!")
