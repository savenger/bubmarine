extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_tree_entered() -> void:
	await get_tree().create_timer(1).timeout
	var space_state = get_world_3d().direct_space_state
	var raycast = PhysicsRayQueryParameters3D.create(global_transform.origin, global_transform.origin + Vector3(0, -5000, 0))
	var collision = space_state.intersect_ray(raycast)
	if collision:
		global_transform.origin.y = collision.position.y
		#print("setting coral down to %s" % str(global_transform.origin.y))
	else:
		#print("NO COLLISION!!!!")
		pass
