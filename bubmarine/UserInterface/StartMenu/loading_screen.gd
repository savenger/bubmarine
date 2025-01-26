extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func start():
	visible = true
	$LoadLabel.text = "3"
	$LoadTimer.start(1)


func _on_load_timer_timeout() -> void:
	if $LoadLabel.text == "3":
		$LoadLabel.text = "2"
		$LoadTimer.start(1)
		return
	if $LoadLabel.text == "2":
		$LoadLabel.text = "1"
		$LoadTimer.start(1)
		return
	if $LoadLabel.text == "1":
		$LoadLabel.text = "0"
		$LoadTimer.start(0.5)
		return
	if $LoadLabel.text == "0":
		visible = false
