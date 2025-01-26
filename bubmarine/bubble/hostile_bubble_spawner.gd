class_name hostile_bubble_spawner
extends Node3D

@export var range_min : float
@export var range_max : float
@export var spawn_delay : float
@export var hostile_bubble : PackedScene
@export var max_bubbles : int

var level : level
var players : Array[Node3D]
var spawned_bubbles : Array[HostileBubble]

func set_data(l : level, p : Array[Node3D]):
	level = l
	players = p	
	
func _enter_tree():
	assert(level != null)
	assert(player != null)
	
	var timer := Timer.new()
	timer.timeout.connect(spawn_new_bubble)
	add_child(timer)
	timer.one_shot = false
	timer.wait_time = spawn_delay
	timer.start()

func spawn_new_bubble():
	var closest_collectable := level.get_nearest_collectable(global_position)
	if(closest_collectable == Vector3.INF) : return
	
	var global_direction := (closest_collectable - global_position).normalized()
	var spawn_position := global_position + global_direction * randf_range(range_min, range_max)
	var bubble := hostile_bubble.instantiate() as HostileBubble
	bubble.pathfinding_targets = players
	level.add_child(bubble)
	bubble.global_position = spawn_position
	
	spawned_bubbles.append(bubble)
	if(spawned_bubbles.size() > max_bubbles):
		var v := spawned_bubbles[0]
		if v != null && is_instance_valid(v) : v.queue_free()
		spawned_bubbles.remove_at(0)
