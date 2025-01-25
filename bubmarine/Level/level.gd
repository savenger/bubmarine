extends Node3D

var current_player_chunk_pos: Vector2
var local_player: Node
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var proc_gen: bool
@onready var _menu = $lblIP

var player_scores = {}

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
	if local_player and proc_gen:
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
	
	if local_player:
		$Position.text = str(local_player.global_transform.origin)

func start_hosting() -> void:
	peer.create_server(1234)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	
func join_game(ip_text: String) -> void:
	peer.create_client(ip_text, 1234)
	multiplayer.multiplayer_peer = peer

func _on_btn_host_pressed() -> void:
	start_hosting()

func _on_btn_join_pressed() -> void:
	join_game($txtJoin.text)

func _on_collect(player_id):
	print(player_id)
	if not player_id in player_scores.keys():
		player_scores[player_id] = 0
	player_scores[player_id] += 1
	$lblBubbles.text = str(player_scores)
	get_nearest_collectable_delayed()

func get_nearest_collectable(player_pos):
	var dist = 999999
	var nearest = null
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

func _add_player(id = 1) -> void:
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	var cam = get_node("Camera3D")
	remove_child(cam)
	player.add_child(cam)
	if id == 1:
		local_player = player
		var bubble = preload("res://bubble/bubble.tscn").instantiate()
		bubble.transform.origin.z -= 10
		add_child(bubble)
		player.connect("collected", _on_collect)
		$Sonar.player = player
