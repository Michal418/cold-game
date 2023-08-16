extends Node2D


signal clicked(sender, mouse_position)


@export var interactable = true


func _ready():
	$StaticBody2D/CollisionShape2D.disabled = not interactable

func _on_static_body_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit(self, event.global_position)
