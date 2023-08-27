extends CanvasLayer


signal main_exited

var can_unpause = false
var dsum = 0.0


func quit_game():
	main_exited.emit()
	get_tree().quit()

func unpause():
	visible = false
	can_unpause = false
	dsum = 0.0
	get_tree().paused = false

func to_menu():
	main_exited.emit()

	get_node("/root/").add_child(load("res://main_menu.tscn").instantiate())
	get_node("/root/Main").queue_free()

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

func _on_menu_button_down():
	get_tree().paused = false
	to_menu()

