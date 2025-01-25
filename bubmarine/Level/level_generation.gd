class_name LevelGeneration extends Node

const MAIN_OFFSET = 1
const FLOOR_HEIGHT = 0.8

var rng = RandomNumberGenerator.new()

var rocks = [
	preload("res://Level/rock1.tscn"),
	preload("res://Level/rock2.tscn"),
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generate_rock():
	var r = rocks[randi() % len(rocks)].instantiate()
	return r

func tiles_present_in_chunk(chunk_position):
	if LevelData.map.has(chunk_position.x):
		if LevelData.map[chunk_position.x].has(chunk_position.y):
			#print("tiles_present_in_chunk(x: %s, y: %s)" % [str(chunk_position.x), str(chunk_position.y)])
			return true
	return false

func generate_tiles(position: Vector2):
	print("have go generate tile in %s, %s and around" % [str(position.x), str(position.y)])
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
			#var t = get_random_tile(create_collectable)
			#add_child(t)
			#t.global_transform.origin.x = chunk_position.x * LevelData.CHUNK_SIZE * LevelData.TILE_SIZE + x * LevelData.TILE_SIZE - LevelData.TILE_SIZE / 2
			#t.global_transform.origin.z = chunk_position.y * LevelData.CHUNK_SIZE * LevelData.TILE_SIZE + z * LevelData.TILE_SIZE - LevelData.TILE_SIZE / 2
			if create_collectable:
				var height = 0
				#for c in t.get_children():
				#	if c.name == "Collectable":
				#		height = c.transform.origin.y
				#		break
				#LevelData.collectable_locations.append(t.global_transform.origin + Vector3(0, height, 0))
				#print("collectable is here: x:%s, y:%s, z:%s" % [str(t.global_transform.origin.x), str(t.global_transform.origin.y), str(t.global_transform.origin.z)])
			#if x == 0 and z == 0:
			#	print("that is: %s, %s" % [str(t.global_transform.origin.x), str(t.global_transform.origin.z)])
	# place tree between two random tiles
	var rx = rng.randi() % LevelData.CHUNK_SIZE
	var rz = rng.randi() % LevelData.CHUNK_SIZE
	#var t = generate_tree()
	#add_child(t)
	#t.global_transform.origin.x = chunk_position.x * LevelData.CHUNK_SIZE * LevelData.TILE_SIZE + rx * LevelData.TILE_SIZE
	#t.global_transform.origin.z = chunk_position.y * LevelData.CHUNK_SIZE * LevelData.TILE_SIZE + rz * LevelData.TILE_SIZE - LevelData.TILE_SIZE / 2
	if not LevelData.map.has(chunk_position.x):
		LevelData.map[chunk_position.x] = Dictionary()
	LevelData.map[chunk_position.x][chunk_position.y] = 1
