extends RigidBody3D

signal collected

var move_speed = 1.2
var turn_speed = 0.3
var target_velocity = Vector3.ZERO
var torque : int = 20
var acc : float = 0.0

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var rotation_direction : Vector3 = Vector3(0, 0, 0)
	if Input.is_action_just_pressed("horn"):
		if !$AudioHorn.playing:
			$AudioHorn.play()
	if Input.is_action_pressed("move_right"):
		rotation_direction.y -= turn_speed
	if Input.is_action_pressed("move_left"):
		rotation_direction.y += turn_speed
	if Input.is_action_pressed("move_forward"):
		acc = move_speed
	else:
		acc = 0
	if Input.is_action_pressed("move_back"):
		acc = -move_speed / 2
		pass
	state.apply_torque(rotation_direction * torque)
	state.apply_force(global_basis.z * 100 * acc)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "BubbleCollision":
		body.get_parent().hide()
		body.get_parent().queue_free()
		emit_signal("collected", multiplayer.get_unique_id())
