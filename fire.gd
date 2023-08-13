extends Node2D

signal clicked(sender, fire_position: Vector2)

const Temperature = preload("res://temperature.gd")
const Player = preload("res://player.gd")

var temperature: Temperature = null
var player: Player = null

@onready var light = $PointLight2D
@onready var color_rect = $Body
@onready var label = $DebugLabel

@export var max_temperature = 750.0
@export var max_fuel = max_temperature * 4
@export var refuel_amount = max_fuel / 6
var refuel_limit = max_fuel - refuel_amount

var internal_temperature = GridBlock.new(max_temperature, 0.2, GridMaterial.STATE.GAS)
var fuel = max_fuel

func initialize(p_temperature: Temperature, p_player: Player):
	temperature = p_temperature
	player = p_player
	
func refuel():
	fuel = clamp(fuel + refuel_amount, 0, max_fuel)

func temperature_interaction(updated_block: GridBlock, _grid_block: GridBlock):
	internal_temperature.celsius = updated_block.celsius

func _process(_delta):
	if internal_temperature.celsius < max_temperature and fuel > 0:
		var dt = min(max_temperature - internal_temperature.celsius, fuel)
		internal_temperature.celsius += dt
		fuel -= dt
		
	label.text = "%.2f fuel\n%.2f \u00b0C" % [fuel, internal_temperature.celsius]

	if fuel > refuel_limit:
		light.energy = 1.8
		color_rect.color = Color('ff1414')
	else:
		light.energy = internal_temperature.celsius / max_temperature * 1.5
		color_rect.color = Color('eb391c')


func _on_player_died():
	set_process(false)
	set_physics_process(false)


func _on_static_body_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
		clicked.emit(self, position)
