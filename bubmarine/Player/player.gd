class_name player
extends RigidBody3D

signal collected
signal health_changed(health:float)

@export var move_speed := 1.0
@export var turn_speed := 0.3
@export var torque : int = 50
@export var hatch_controller : player_hatch
@export var hatch_speedfactor : float
@export var swing_force := 0.8
@export var health := 1.0

var acc : float = 0.0
var nearest_collectable = null

func _enter_tree():
	print("setting authority to %s" % str(name.to_int()))
	set_multiplayer_authority(name.to_int())

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var rotation_direction : Vector3 = Vector3(0, 0, 0)
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
	acc *= hatch_speedfactor if hatch_controller._is_open else 1
	state.apply_force(-global_basis.z * 100 * acc)

func _process(delta:float):
	hatch_controller.set_open(Input.is_action_pressed("open_hatch"))

func get_nearest_collectable_delayed():
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", Callable(self, "get_nearest_collectable"))
	timer.one_shot = true
	timer.wait_time = 2
	timer.start()

func set_nearest_collectable(collectable):
	nearest_collectable = collectable

func get_nearest_collectable():
	set_nearest_collectable(get_parent().get_nearest_collectable(global_transform.origin))

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "BubbleCollision":
		print("I am player %s" % (str(get_multiplayer_authority())))
		body.get_parent().hide()
		body.get_parent().queue_free()
		if is_multiplayer_authority():
			return
		var i = LevelData.collectable_locations.find(body.global_transform.origin)
		LevelData.collectable_locations.remove_at(i)
		emit_signal("collected", multiplayer.get_unique_id(), body.global_transform.origin)
		get_nearest_collectable_delayed()

func _on_ready() -> void:
	get_nearest_collectable_delayed()

func change_health_state(delta : float):
	var final_health := clampf(health + delta, 0, 1)
	if final_health == health: return
	health = final_health
	print("me health "+str(health))
	health_changed.emit(health)

	if health == 0:
		self.queue_free()
	
