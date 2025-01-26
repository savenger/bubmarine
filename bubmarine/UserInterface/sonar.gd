extends Node3D

@export var target : Vector3
@export var player : Node3D

## A higher value causes larger movements of the dot,
## giving a better estimate of the target position while close
## but a worse estimate while far away.
@export var sensitivity: float = 0.25

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player and target and player.nearest_collectable:
		#print("Player: %s, Collectable: %s, target: %s" % [player.global_transform.origin, player.nearest_collectable, str(target)])
		var dist = player.nearest_collectable - player.global_transform.origin
		var relative_position = Vector2(dist.x, dist.z)
		var relative_distance = min(relative_position.length() * sensitivity, $SonarPanel.size.x / 2.15)
		var normalized_position = relative_position.normalized() * relative_distance
		$SonarPanel/Target.position = $SonarPanel/SonarCenter.position + normalized_position
