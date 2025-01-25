class_name bullet_shooter
extends Node3D

@export var player: RigidBody3D 
@export var cooldown: float = 0.2
@export var bullet_inflation: float = 0.5
@export var bullet_speed: float = 10

var bullet = preload("res://bubble/BulletBubble.tscn")

var can_shoot = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("shoot_guns") and can_shoot:
		can_shoot = false
		$Timer.start(cooldown)
		var new_bullet = bullet.instantiate()
		player.get_parent().add_child(new_bullet)
		new_bullet.global_position = self.global_position
		new_bullet.bullet_direction = $Marker3D.global_position - self.global_position
		new_bullet.bullet_inflation = bullet_inflation
		new_bullet.bullet_speed = bullet_speed + player.linear_velocity.length()



func _on_cooldown_timeout() -> void:
	can_shoot = true
