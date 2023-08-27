extends Node2D


signal clicked(sender, mouse_position)


@export var interactable = true

var dsum = 0.0


func serialize():
	return var_to_bytes({
		"scene_file_path": scene_file_path,
		"position": position
	})

func deserialize(serialized_data):
	position = serialized_data["position"]

func _ready():
	if interactable:
		interactable = false
		set_process(true)
	else:
		set_process(false)

	$StaticBody2D/CollisionShape2D.disabled = not interactable

func _process(delta):
	dsum += delta

	if dsum > 0.15:
		interactable = true
		$StaticBody2D/CollisionShape2D.disabled = false
		set_process(false)

func _on_static_body_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit(self, event.global_position)
