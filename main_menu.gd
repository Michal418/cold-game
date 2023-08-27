extends MarginContainer


var main_scene = preload("res://main.tscn")

func _ready():
	$VBoxContainer/LoadButton.disabled = not FileAccess.file_exists("user://saved.dat")

func _on_play_button_down():
	get_node("/root/MainMenu").queue_free()
	get_node("/root").add_child(main_scene.instantiate())
	get_node("/root/Main").call_deferred("initialize")

func _on_exit_button_down():
	get_tree().quit()

func _on_load_button_down():
	get_node("/root/MainMenu").queue_free()
	get_node("/root").add_child(main_scene.instantiate())
	get_node("/root/Main").call_deferred("deserialize")
