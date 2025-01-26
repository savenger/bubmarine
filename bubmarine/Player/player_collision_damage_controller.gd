class_name player_collision_damage_controller
extends Node

@export var player:player
@export var health_change_per_collision:= -0.1

func _enter_tree():
	player.body_entered.connect(on_body_entered)
	
func _exit_tree():
	player.body_entered.disconnect(on_body_entered)
	
func on_body_entered(v:Node):
	player.change_health_state(health_change_per_collision)
