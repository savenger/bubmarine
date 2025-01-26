class_name MainMenu
extends Control

var peer = ENetMultiplayerPeer.new()
@export_file("*.tscn") var start_level = "res://Level/Level.tscn"
@export var ip_field: LineEdit
@export var game_over : game_over_screen
@export var score_interface : score_interface
@export var Bubble : Node
@export var MenuMusic : AudioStreamPlayer
@export var BackGroundLoopMusic  : AudioStreamPlayer


@onready var menu_container = $StartMenu

var game_level: level

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
	reset_gamestate()
	print_debug(get_local_ip())
	_switch_menu_mode("MainMenu")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func reset_gamestate() -> void:
	if game_level:
		game_level.queue_free()
	LevelData.reset()
	var level = load(start_level)
	game_level = level.instantiate()
	game_level.set_menu(self)
	add_child(game_level)
	$lblIP.text = "Local IP address: %s, unique_id: %s, seed: %s" % [get_local_ip(), multiplayer.get_unique_id(), str(game_level.get_seed())]


func back_to_menu() -> void:
	_switch_menu_mode("MainMenu")
	menu_container.visible = true


func _on_start_button_pressed() -> void:
	_start_game()
	game_level.start_hosting()
	$lblIP.text = "Local IP address: %s, unique_id: %s, seed: %s" % [get_local_ip(), multiplayer.get_unique_id(), str(game_level.get_seed())]


func _on_join_button_pressed() -> void:
	_switch_menu_mode()
	$Level.join_game(ip_field.text)
	menu_container.visible = false
	
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_timer_update_seed_timeout"))
	timer.one_shot = true
	timer.wait_time = 2
	timer.start()

func _on_timer_update_seed_timeout() -> void:
	$lblIP.text = "Local IP address: %s, unique_id: %s, seed: %s" % [get_local_ip(), multiplayer.get_unique_id(), str(game_level.get_seed())]
	


func _start_game() -> void:
	LevelData.reset()
	Bubble.hide()
	_switch_menu_mode()
	menu_container.visible = false
	MenuMusic.stop()
	BackGroundLoopMusic.play()
	$LoadingScreen.start()
	
	
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
	menu_container.visible = false
	$GameOverScreen.visible = true
	


func _on_continue_button_pressed() -> void:
	menu_container.visible = false
