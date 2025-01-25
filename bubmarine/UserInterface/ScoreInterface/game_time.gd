extends Label


var time_passed = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _display_game_time() -> void:
	var seconds = time_passed % 60
	var minutes = (time_passed / 60) % 60
	var hours = minutes / 60 / 60
	if hours <= 0:
		text = "%02d:%02d" % [minutes, seconds]
	else:
		text = "%02d:%02d:%02d" % [hours, minutes, seconds]

func _on_timer_timeout() -> void:
	time_passed += 1
	_display_game_time()
