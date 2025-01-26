class_name game_over_screen
extends PanelContainer


@export var score_label: Label
@export var main_menu: MainMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func show_and_set_score(points: int):
	visible = true
	set_score(str(points))

func set_score(points: String = "") -> void:
	score_label.text = points

func _on_restart_button_pressed() -> void:
	visible = false
	main_menu.reset_gamestate()


func _on_end_run_button_pressed() -> void:
	main_menu.back_to_menu()
	visible = false
	main_menu.reset_gamestate()
