extends Node
var map = {}
const CHUNK_SIZE = 4
const TILE_SIZE = 100
const ROCK_SIZE = 5
var collectable_locations = []
var tile_count = 0

func reset():
	map = {}
	collectable_locations = []
	tile_count = 0
