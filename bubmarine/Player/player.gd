extends RigidBody3D

var move_speed = 1
var turn_speed = 0.3
var target_velocity = Vector3.ZERO
@export var torque : int = 60
var acc : float = 0.0
@export var swing_force = 0.8

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
	elif Input.is_action_pressed("move_back"):
		acc = -move_speed * 1.5
		pass
	else:
		acc = 0
		
	var target_tilt_z = float(rotation_direction.y) * swing_force 
	rotation.z = lerp(rotation.z, target_tilt_z, 0.06) 
	rotation.x = lerp(rotation.x, 0.0, 0.2)
		
	state.apply_torque(rotation_direction * torque)
	state.apply_force(global_basis.z * 100 * acc)
