class_name LevelGeneration extends Node

const MAIN_OFFSET = 1
const FLOOR_HEIGHT = 0.8
const ROCK_SIZE = 5

var rng = RandomNumberGenerator.new()

var floor = preload("res://Level/floor.tscn")

var rocks = [
	preload("res://Level/rock1.tscn"),
	preload("res://Level/rock2.tscn"),
	preload("res://Level/rock3.tscn"),
]

var corals = [
	preload("res://Level/coral1.tscn"),
	preload("res://Level/coral2.tscn"),
	preload("res://Level/coral3.tscn"),
	preload("res://Level/coral4.tscn"),
	preload("res://Level/coral5.tscn"),
]

var arcs = [
	preload("res://Level/arc.tscn"),
]

var collectables = [
	preload("res://bubble/bubble.tscn")
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func init_rng(new_seed = 0):
	if new_seed == 0:
		rng.randomize()
		print("set new seed: %s" % rng.seed)
		print("set new seed: %s" % rng.seed)
		print("set new seed: %s" % rng.seed)
	else:
		rng.seed = new_seed
		print("set server seed: %s" % rng.seed)
	return rng.seed

@rpc("any_peer")
func get_seed():
	return rng.seed

@rpc("authority", "call_remote", "reliable")
func set_seed(new_seed: int):
	print("Got seed from server: %s" % str(new_seed))
	rng.seed = new_seed
	get_parent().process_mode = Node.PROCESS_MODE_ALWAYS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_arc():
	var a : Node3D = arcs[rng.randi() % len(arcs)].instantiate()
	return a

func generate_coral():
	var c : Node3D = corals[rng.randi() % len(corals)].instantiate()
	c.rotate_y(rng.randf())
	return c

func generate_rock():
	var r : Node3D = rocks[rng.randi() % len(rocks)].instantiate()
	r.rotate_y(rng.randf())
	return r

func tiles_present_in_chunk(chunk_position):
	if LevelData.map.has(chunk_position.x):
		if LevelData.map[chunk_position.x].has(chunk_position.y):
			#print("tiles_present_in_chunk(x: %s, y: %s)" % [str(chunk_position.x), str(chunk_position.y)])
			return true
	return false

func generate_collectable():
	var c = collectables[rng.randi() % len(collectables)].instantiate()
	return c

@rpc
func get_random_tile(create_collectable: bool):
	var grid = Dictionary()
	var created_collectable = false
	#var r = rng.randf_range(0, 10.0)
	var f = floor.instantiate()
	for x in range(int(LevelData.TILE_SIZE / LevelData.ROCK_SIZE)):
		for y in range(int(LevelData.TILE_SIZE / LevelData.ROCK_SIZE)):
			if rng.randf() < 0.1:
				#print("creating rock at: " + str(x) + " and " + str(y))
				var rock = generate_rock()
				f.add_child(rock)
				rock.transform.origin.x = x * LevelData.ROCK_SIZE
				rock.transform.origin.z = y * LevelData.ROCK_SIZE
				#print("generated rock at %s, %s" % [str(rock.transform.origin.x), str(rock.transform.origin.z)])
				if not grid.has(rock.transform.origin.x):
					grid[rock.transform.origin.x] = []
				grid[rock.transform.origin.x].append(rock.transform.origin.z)
			elif rng.randf() < 0.2:
				var coral = generate_coral()
				f.add_child(coral)
				coral.transform.origin.x = x * LevelData.ROCK_SIZE
				coral.transform.origin.z = y * LevelData.ROCK_SIZE
			else:
				if create_collectable and not created_collectable:
					var c = generate_collectable() as Node3D
					f.add_child(c)
					c.transform.origin.x = x * LevelData.ROCK_SIZE
					c.transform.origin.z = y * LevelData.ROCK_SIZE
					c.add_to_group("collectable", true)
					created_collectable = true
	for x in grid.keys():
		for y in grid[x]:
			#print("%s, %s in the grid" % [str(x), str(y)])
			var arc_possible = false
			var arc_start = x
			var arc_mid = x + LevelData.ROCK_SIZE
			var arc_end = x  + 2 * LevelData.ROCK_SIZE
			if (arc_start) in grid.keys() and (arc_end) in grid.keys():
				arc_possible = (y in grid[arc_start]) and (y in grid[arc_end]) and (arc_mid not in grid[x])
			if arc_possible: #randf() < 0.5:
				# print("setting arc from %s,%s to %s,%s" % [arc_start, y, arc_end, y])
				var arc = generate_arc()
				f.add_child(arc)
				arc.transform.origin.x = arc_mid
				arc.transform.origin.z = y
	return f

func generate_tiles(position: Vector2):
	# print("have go generate tile in %s, %s and around" % [str(position.x), str(position.y)])
	if not tiles_present_in_chunk(position):
		generate_tiles_in_chunk(position)
	for i in range(3):
		for j in range(3):
			var chunk_pos = Vector2(position.x + i - 1, position.y + j - 1)
			# print("around would be %s, %s" % [str(chunk_pos.x), str(chunk_pos.y)])
			if not tiles_present_in_chunk(chunk_pos):
				generate_tiles_in_chunk(chunk_pos)

func generate_tiles_in_chunk(chunk_position):
	#print("generate_tiles_in_chunk (x: %s, y: %s)" % [str(chunk_position.x), str(chunk_position.y)])
	# generate chunks around in 1 "chunk radius" (1 chunk = TILE_SIZE x TILE_SIZEm)
	var r = rng.randi() % (LevelData.CHUNK_SIZE * LevelData.CHUNK_SIZE)
	for x in range(LevelData.CHUNK_SIZE):
		for z in range(LevelData.CHUNK_SIZE):
			var create_collectable = (x * LevelData.CHUNK_SIZE) + z == int(r)
			var t = get_random_tile(create_collectable)
			add_child(t)
			t.global_transform.origin.x = chunk_position.x * LevelData.CHUNK_SIZE * LevelData.TILE_SIZE + x * LevelData.TILE_SIZE - LevelData.TILE_SIZE / 2
			t.global_transform.origin.z = chunk_position.y * LevelData.CHUNK_SIZE * LevelData.TILE_SIZE + z * LevelData.TILE_SIZE - LevelData.TILE_SIZE / 2
			if create_collectable:
				LevelData.collectable_locations.append(t.global_transform.origin)
				# print("collectable is here: x:%s, y:%s" % [str(t.global_transform.origin.x), str(t.global_transform.origin.z)])
			#if x == 0 and z == 0:
			#	print("that is: %s, %s" % [str(t.global_transform.origin.x), str(t.global_transform.origin.z)])
			LevelData.tile_count += 1
			# print("generated %s th tile at %s, %s" % [str(LevelData.tile_count), str(t.global_transform.origin.x), str(t.global_transform.origin.z)])
	# place tree between two random tiles
	#var rx = rng.randi() % LevelData.CHUNK_SIZE
	#var rz = rng.randi() % LevelData.CHUNK_SIZE
	#var t = generate_tree()
	#add_child(t)
	#t.global_transform.origin.x = chunk_position.x * LevelData.CHUNK_SIZE * LevelData.TILE_SIZE + rx * LevelData.TILE_SIZE
	#t.global_transform.origin.z = chunk_position.y * LevelData.CHUNK_SIZE * LevelData.TILE_SIZE + rz * LevelData.TILE_SIZE - LevelData.TILE_SIZE / 2
	if not LevelData.map.has(chunk_position.x):
		LevelData.map[chunk_position.x] = Dictionary()
	LevelData.map[chunk_position.x][chunk_position.y] = 1
