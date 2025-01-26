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
	if v.name == "BubbleCollision":
		v.get_parent().hide()
		v.get_parent().queue_free()
		if not is_multiplayer_authority():
			return
		_on_bubble_popped(get_multiplayer_authority(), v.global_transform.origin)

func count_as_popped(collectable_position):
	var i = LevelData.collectable_locations.find(collectable_position)
	if i > -1:
		LevelData.collectable_locations.remove_at(i)
	get_parent().get_nearest_collectable_delayed()

func _on_bubble_popped(player_id, collectable_position):
	print(player_id)
	count_as_popped(collectable_position)
	if player_id == 1 and multiplayer.get_unique_id() == 1:
		_on_bubble_popped_inform(player_id, collectable_position)
	else:
		_on_bubble_popped_inform.rpc(player_id, collectable_position)

@rpc("authority", "reliable")
func _remote_player_popped(player_id, collectable_position):
	count_as_popped(collectable_position)

@rpc("any_peer", "reliable")
func _on_bubble_popped_inform(player_id, collectable_position):
	print("got informed from player %s about %s" % [str(player_id), str(collectable_position)])
	for peer in multiplayer.get_peers():
		print("considering %s" % (str(peer)))
		if peer != player_id:
			print("informing %s" % str(peer))
			_remote_player_popped.rpc_id(peer, collectable_position)
