extends Node3D

@export var target : Vector3
@export var player : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(player) and target:
		#print("Player: %s, Collectable: %s, target: %s" % [player.global_transform.origin, player.nearest_collectable, str(target)])
		var dist = player.nearest_collectable - player.global_transform.origin
		var new_pos = $SonarPanel/SonarCenter.position + Vector2(dist.x, dist.z)
		$SonarPanel/Target.position = Vector2(max(0, min(new_pos.x, 128)), max(0, min(new_pos.y, 128)))
