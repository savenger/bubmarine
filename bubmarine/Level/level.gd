class_name level
extends Node3D

var current_player_chunk_pos: Vector2
var local_player: Node = null
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var hostile_bubble_spawner_scene : PackedScene
@export var proc_gen: bool

func get_seed():
	return $level_generator.rng.seed

var player_scores = {}

var collectable = preload("res://Level/rock1.tscn")

var ip_adress :String
var players : Array[Node3D]

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
	$lblIP.text = "Local IP address: %s, unique_id: %s, seed: %s" % [get_local_ip(), multiplayer.get_unique_id(), str($level_generator.rng.seed)]
	print_debug(get_local_ip())
	if proc_gen:
		remove_child(get_node("static"))

func pos_to_chunk_pos(position):
	var x = floor(position.x / (LevelData.CHUNK_SIZE * LevelData.TILE_SIZE))
	var z = floor(position.z / (LevelData.CHUNK_SIZE * LevelData.TILE_SIZE))
	return Vector2(x, z)

func pause():
	# show / hide menu
	var new_pause_state: bool = not get_tree().paused
	if new_pause_state:
		#$Menu.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		#$Menu.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print("get_tree().paused: {paused}".format({"paused": get_tree().paused}))
	get_tree().paused = new_pause_state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# print("$level_generator.rng.seed: %s, local_player: %s" % [str($level_generator.rng.seed), str(local_player)])
	#print("processing")
	if local_player and proc_gen:
		var chunk_pos: Vector2 = pos_to_chunk_pos(local_player.global_transform.origin)
		if chunk_pos.x != current_player_chunk_pos.x or chunk_pos.y != current_player_chunk_pos.y:
			current_player_chunk_pos = chunk_pos
			local_player.set_nearest_collectable(get_nearest_collectable(local_player.global_transform.origin))
			$level_generator.generate_tiles(chunk_pos)
	
	if Input.is_action_just_released("volume_up"):
		LevelData.volume_up()
	if Input.is_action_just_released("volume_down"):
		LevelData.volume_down()
	
	if Input.is_action_just_pressed("menu"):
		pause()
	
	if local_player:
		$Position.text = str(local_player.global_transform.origin)

func start_hosting() -> void:
	peer.create_server(1234)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	$level_generator.init_rng()
	_add_player()
	
func join_game(ip_text: String) -> void:
	peer.create_client(ip_text, 1234)
	multiplayer.multiplayer_peer = peer

func _on_btn_host_pressed() -> void:
	start_hosting()

func _on_btn_join_pressed() -> void:
	join_game($txtJoin.text)

@rpc("authority", "reliable")
func _on_collect(player_id, collectable_position):
	print(player_id)
	if not player_id in player_scores.keys():
		player_scores[player_id] = 0
	player_scores[player_id] += 1
	$lblBubbles.text = str(player_scores)
	get_nearest_collectable_delayed()
	print("find collectable: %s" % str(collectable_position))
	var i = LevelData.collectable_locations.find(collectable_position)
	LevelData.collectable_locations.remove_at(i)
	get_nearest_collectable_delayed()
	_on_collect_inform.rpc(player_id, collectable_position)

@rpc("any_peer", "reliable")
func _on_collect_inform(player_id, collectable_position):
	print("got informed from player %s about %s" % [str(player_id), str(collectable_position)])
	for peer in multiplayer.get_peers():
		print("informing %s" % str(peer))
		_on_collect.rpc_id(peer, player_id, collectable_position)
	_on_collect(player_id, collectable_position)

func get_nearest_collectable(player_pos) -> Vector3:
	var dist = 999999
	var nearest = Vector3(0,0,0)
	for vec in LevelData.collectable_locations:
		var d = player_pos.distance_to(vec)
		if  d < dist:
			nearest = vec
			dist = d
	return nearest

func get_nearest_collectable_delayed():
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", Callable(self, "get_nearest_collectable"))
	timer.one_shot = true
	timer.wait_time = 2
	timer.start()

#@rpc("authority", "call_remote", "reliable")
func _add_player(id: int = 1) -> void:
	var _player := player_scene.instantiate() as player
	_player.name = str(id)
	call_deferred("add_child", _player)
	
	var spawner := hostile_bubble_spawner_scene.instantiate() as hostile_bubble_spawner
	spawner.set_data(self, players)
	_player.add_child(spawner)
	players.append(_player)
	_player.collected.connect(_on_collect)
	if id == 1:
		local_player = _player
		$Sonar.player = _player
		var cam = get_node("Camera3D")
		remove_child(cam)
		_player.add_child(cam)
		process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		$level_generator.set_seed.rpc_id(id, get_seed())


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node.name == str(multiplayer.get_unique_id()):
		local_player = node
		var cam = get_node("Camera3D")
		remove_child(cam)
		$Sonar.player = local_player
		local_player.add_child(cam)
