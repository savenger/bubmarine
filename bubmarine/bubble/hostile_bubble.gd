class_name HostileBubble
extends RigidBody3D

@export var pathfinding_targets: Array[Node3D]
@export var movement_speed: float = 2
@export var pop_size: float = 2.0

@export_group("BubbleSize")
@export var size: float = 1.0
@export var mesh: MeshInstance3D
@export var obstacle_collision: CollisionShape3D
@export var player_collision: CollisionShape3D

var current_target
var previous_size = size
@onready var mesh_base_size := mesh.scale
@onready var obstacle_collision_base_size := obstacle_collision.scale
@onready var player_collision_base_size := player_collision.scale

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_target = _find_closest_target()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_move_towards_target()
	_adjust_bubble_size()
	_pop_bubble()


func _pop_bubble() -> void:
	if size >= pop_size:
		visible = false
		queue_free()


func _adjust_bubble_size() -> void:
	if previous_size == size:
		return
	mesh.scale = mesh_base_size * size
	obstacle_collision.scale = obstacle_collision_base_size * size
	player_collision.scale = player_collision_base_size * size
	
	previous_size = size


func _move_towards_target() -> void:
	if current_target == null:
		return
		
	var direction = global_position.direction_to(current_target.global_position)
	linear_velocity = direction * movement_speed


func _find_closest_target() -> Node3D:
	var closest_target = null
	var closest_distance = INF
	for target in pathfinding_targets:
		var distance = global_position.distance_squared_to(target.global_position)
		if  distance < closest_distance:
			closest_target = target
			closest_distance = distance
	
	return closest_target


func _on_player_contact(body: Node3D) -> void:
	visible = false
	queue_free()


func inflate_bubble(scale_amount: float = randf_range(0.0, 0.2)) -> void:
	size += scale_amount
