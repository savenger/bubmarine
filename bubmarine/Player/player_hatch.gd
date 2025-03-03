class_name player_hatch
extends Node

@export var animator : AnimationPlayer

var _is_open : bool

func _ready():
	_is_open = true
	set_open(false)

func set_open(set_open: bool) -> void:
	if _is_open == set_open: return
	_is_open = set_open
	var reverse := true if !set_open else false
	
	if reverse:
		animator.play_backwards("HatchOpen")
	else:
		animator.play("HatchOpen")
