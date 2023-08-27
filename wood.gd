extends Node2D


const Player = preload("res://player.gd")

@export var interactable = true


func serialize():
	return {
		"scene_file_path": scene_file_path,
		"position": position
	}

func deserialize(serialized_data):
	position = serialized_data['position']

func _ready():
	$Area2D.monitorable = interactable
	$Area2D.monitoring = interactable

func _on_area_2d_body_entered(body):
	if not interactable:
		return

	if body.is_in_group("player") and body.carying == Player.CARRY_ITEMS.NONE:
		body.gain_fuel()
		queue_free()
