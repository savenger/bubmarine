extends Node3D

var current_player_chunk_pos: Vector2
var local_player: Node
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@onready var _menu = $lblIP

var collectable = preload("res://Level/rock1.tscn")

var ip_adress :String

func get_local_ip() -> String:
	for address in IP.get_local_addresses():
		if "." in address and not address.begins_with("127.") and not address.begins_with("169.254."):
			if address.begins_with("192.168.") or address.begins_with("10.") or (address.begins_with("172.") and int(address.split(".")[1]) >= 16 and int(address.split(".")[1]) <= 31):
				return address
	return "unknown"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_player_chunk_pos.x = -1000
	current_player_chunk_pos.y = -1000
	$lblIP.text = "Local IP address: " + get_local_ip()
	print_debug(get_local_ip())

func pos_to_chunk_pos(position):
	var x = floor(position.x / (LevelData.CHUNK_SIZE * LevelData.TILE_SIZE))
	var z = floor(position.z / (LevelData.CHUNK_SIZE * LevelData.TILE_SIZE))
	return Vector2(x, z)

func pause():
	# show / hide menu
	var new_pause_state: bool = not get_tree().paused
	if new_pause_state:
		$Menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		$Menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("get_tree().paused: {paused}".format({"paused": get_tree().paused}))
	get_tree().paused = new_pause_state
	for c in _menu.get_children():
		_menu.remove_child(c)
		c.queue_free()
	for size in range(3):
		for c in LevelData.collectable_count[size]:
			var cmi = collectable.instantiate()
			cmi.found = (c in LevelData.collection[size])
			cmi.size = size
			cmi.sprite = c
			print("adding bubble %s from size %s" % [str(cmi.sprite), str(cmi.size)])
			_menu.add_child(cmi)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if local_player:
		var chunk_pos: Vector2 = pos_to_chunk_pos(local_player.global_transform.origin)
		if chunk_pos.x != current_player_chunk_pos.x or chunk_pos.y != current_player_chunk_pos.y:
			current_player_chunk_pos = chunk_pos
			# $Player.set_nearest_collectable(get_nearest_collectable($Player.global_transform.origin))
			$level_generator.generate_tiles(chunk_pos)
	
	if Input.is_action_just_released("volume_up"):
		LevelData.volume_up()
	if Input.is_action_just_released("volume_down"):
		LevelData.volume_down()
	
	if Input.is_action_just_pressed("menu"):
		pause()
	
	

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
	var cam = get_node("Camera3D")
	remove_child(cam)
	player.add_child(cam)
	if id == 1:
		local_player = player
