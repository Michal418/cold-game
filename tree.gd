extends Node2D


signal clicked(sender, mouse_position: Vector2)


func serialize():
	return {
		"scene_file_path": scene_file_path,
		"position": position
	}

func deserialize(serialized_data):
	position = serialized_data['position']

func _on_static_body_2d_input_event(_viewport, event, _shape_idx):
	if Input.is_action_just_pressed("interact"):
		clicked.emit(self, event.global_position)
