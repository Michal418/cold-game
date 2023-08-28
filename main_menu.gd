extends MarginContainer


var main_scene = preload("res://main.tscn")

func _ready():
	$VBoxContainer/LoadButton.disabled = not FileAccess.file_exists("user://saved.dat")

func _on_play_button_down():
#	get_tree().change_scene_to_packed(main_scene)
#	get_node("/root/Main").call_deferred("initialize")
	
	get_tree().current_scene.queue_free()
	var main_instance = main_scene.instantiate()
	get_node("/root").add_child(main_instance, true)
	get_tree().set_current_scene(main_instance)
	get_tree().current_scene.call_deferred("initialize")

func _on_exit_button_down():
	get_tree().quit()

func _on_load_button_down():
#	get_tree().change_scene_to_packed(main_scene)
#	get_node("/root/Main").call_deferred("deserialzie")
	
	get_tree().current_scene.queue_free()
	var main_instance = main_scene.instantiate()
	get_node("/root").add_child(main_instance, true)
	get_tree().set_current_scene(main_instance)
	get_tree().current_scene.call_deferred("deserialize")
