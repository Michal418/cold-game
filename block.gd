extends Node2D

@export var interactable = true
@export var breakable = true
@export var unbreakable_color: Color = Color('#362c38')

@onready var collision_body = $StaticBody2D as StaticBody2D

signal clicked(sender, block_position: Vector2)

var dsum = 0.0


func serialize():
	return {
		"scene_file_path": scene_file_path,
		"position": position
	}

func deserialize(serialized_data):
	position = serialized_data["position"]

func _ready():
	if not interactable:
		var sb = $StaticBody2D
		sb.collision_layer = 0
		sb.collision_mask = 0

	interactable = false

	if not breakable:
		$Body.color = unbreakable_color

func _process(delta):
	dsum += delta

	if dsum > 0.3:
		interactable = true
		set_process(false)

func _on_static_body_2d_input_event(_viewport, event, _shape_idx):
	if not interactable:
		return

	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		clicked.emit(self, position)
