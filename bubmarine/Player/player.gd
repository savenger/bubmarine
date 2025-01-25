extends RigidBody3D

@export var move_speed = 1.0
@export var turn_speed = 0.3
@export var torque : int = 50
@export var hatch_controller : player_hatch
@export var hatch_speedfactor : float
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
	elif Input.is_action_pressed("move_back"):
		acc = -move_speed * 1.5
		pass
	else:
		acc = 0
		
		
	state.apply_torque(rotation_direction * torque)
	acc *= hatch_speedfactor if hatch_controller._is_open else 1
	state.apply_force(-global_basis.z * 100 * acc)

func _process(delta:float):
	hatch_controller.set_open(Input.is_action_pressed("open_hatch"))
	
