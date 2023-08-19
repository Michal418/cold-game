extends MarginContainer


var main_scene = preload("res://main.tscn")


func _on_play_button_down():
	get_tree().change_scene_to_packed(main_scene)

func _on_exit_button_down():
	get_tree().quit()

