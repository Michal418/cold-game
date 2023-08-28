extends Node2D

@export var interactable = true
@export var breakable = true
@export var unbreakable_color: Color = Color('#362c38')
@export var breakable_color: Color = Color('#2e294e')

@onready var collision_body = $StaticBody2D as StaticBody2D

signal clicked(sender, block_position: Vector2)

var n = 2


func serialize():
	return {
		"scene_file_path": scene_file_path,
		"position": position,
		"breakable": breakable
	}

func deserialize(serialized_data):
	position = serialized_data["position"]
	breakable = serialized_data["breakable"]
	interactable = true
	_initialize()

func _initialize():
	if interactable:
		$StaticBody2D.collision_layer = 1
		$StaticBody2D.collision_mask = 4
	else:
		$StaticBody2D.collision_layer = 0
		$StaticBody2D.collision_mask = 0

	if breakable:
		$Body.color = breakable_color
	else:
		$Body.color = unbreakable_color

func _ready():
	_initialize()

func _on_static_body_2d_input_event(_viewport, _event, _shape_idx):
	if not breakable:
		return
		
	if n > 0:
		n -= 1
		return
		
	if Input.is_action_just_pressed("interact"):
		clicked.emit(self, position)

#	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
#		clicked.emit(self, position)
