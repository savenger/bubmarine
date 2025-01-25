extends Control

@export_file("*tscn") var start_scene = "res://Level/Level.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# Start button changes to run the actual game scene
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(start_scene)

# Quits the game for good.
# TODO: add a "do you really want to exit?" menu
func _on_quit_button_pressed() -> void:
	get_tree().quit()
