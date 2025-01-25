extends Button


# Quits the game for good.
# TODO: add a "do you really want to exit?" menu
func _on_quit_button_pressed() -> void:
	get_tree().quit()
