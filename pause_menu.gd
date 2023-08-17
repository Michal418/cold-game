extends CanvasLayer


var can_unpause = false
var dsum = 0.0


func quit_game():
	get_tree().quit()

func unpause():
	visible = false
	can_unpause = false
	dsum = 0.0
	get_tree().paused = false

func _process(delta):
	if can_unpause and Input.is_action_just_pressed('ui_cancel'):
		unpause()

	dsum += delta
	if dsum > 0.1:
		can_unpause = true

func _on_resume_button_down():
	unpause()

func _on_exit_button_down():
	quit_game()
