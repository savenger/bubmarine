class_name BackgroundHatchController
extends Node

@export var animator : AnimationPlayer


func _ready():
	_on_open_timer_timeout()

func _on_open_timer_timeout() -> void:
	animator.play("HatchOpen")
	$CloseTimer.start(randf_range(1, 5))

func _on_close_timer_timeout() -> void:
	animator.play_backwards("HatchOpen")
	$OpenTimer.start(randf_range(10, 50))
