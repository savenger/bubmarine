class_name MainMenu
extends Control

var peer = ENetMultiplayerPeer.new()
@export_file("*.tscn") var start_level = "res://Level/Level.tscn"
@export var ip_field: LineEdit

@onready var menu_container = $StartMenu

var current_menu_mode = "MainMenu"
var replacement_menu_mode = "PauseMenu"

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
	_switch_menu_mode("MainMenu")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	peer.create_server(34)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_start_game)
	_start_game()


func _on_join_button_pressed() -> void:
	peer.create_client(ip_field.text, 1234)
	multiplayer.multiplayer_peer = peer


func _start_game() -> void:
	_switch_menu_mode()
	menu_container.visible = false
	#get_tree().change_scene_to_file(start_level)
	
	
func _switch_menu_mode(new_mode: String = replacement_menu_mode) -> String:
	if new_mode != current_menu_mode:
		replacement_menu_mode = current_menu_mode
		
	current_menu_mode = new_mode
		
	for node in get_tree().get_nodes_in_group(current_menu_mode):
		node.visible = true
	for node in get_tree().get_nodes_in_group(replacement_menu_mode):
		node.visible = false
		
	return current_menu_mode


func _on_back_to_menu_button_pressed() -> void:
	_switch_menu_mode("MainMenu")


func _on_continue_button_pressed() -> void:
	menu_container.visible = false
	
	


func _on_credits_button_pressed() -> void:
	pass # Replace with function body.
