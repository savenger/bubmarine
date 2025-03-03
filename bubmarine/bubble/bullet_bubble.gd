class_name BulletBubble
extends Area3D

var bullet_speed = 5
var bullet_direction = Vector3(0, 0, 0)
var bullet_inflation = 0.5
@export var applied_force_multiplier : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += bullet_direction * bullet_speed * delta


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if body is HostileBubble:
		body.inflate_bubble(bullet_inflation)
	if body is RigidBody3D:
		body.apply_central_impulse(bullet_direction * bullet_speed * applied_force_multiplier)
	queue_free()
