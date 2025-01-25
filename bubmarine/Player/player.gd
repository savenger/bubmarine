extends CharacterBody3D

var move_speed = 2
var turn_speed = 0.3
var target_velocity = Vector3.ZERO

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
func _physics_process(delta):
	
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
		
	var turn_input = 0.0
	
	if Input.is_action_pressed("move_right"):
		turn_input += 1
	if Input.is_action_pressed("move_left"):
		turn_input -= 1
	
	turn_input += Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		#$Pivot.basis = Basis.looking_at(direction)
		
	target_velocity.x = direction.x * move_speed
	target_velocity.z = direction.z * move_speed
	
	if abs(turn_input) < 0.1:
		turn_input = 0
		
	rotation.y -= turn_input * turn_speed * delta
	
	velocity = target_velocity.rotated(Vector3.UP, rotation.y)
	move_and_slide() 	
