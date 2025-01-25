extends Camera3D

@export var follow_offset: Vector3 = Vector3(0, 10, -2)  
@export var look_at_offset: Vector3 = Vector3(0, 2, 0)  

func _process(delta):
	if get_parent():  
		var player_position = get_parent().global_transform.origin
		global_transform.origin = player_position + follow_offset

		
		var look_at_position = player_position + look_at_offset
		look_at(look_at_position, Vector3(0,0,-1))
