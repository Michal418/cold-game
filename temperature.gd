extends Node2D


const World = preload("res://world.gd")

const SOLID_RATE = 10
const GAS_RATE = 4
const TRANSITION_RATE = 75
const SIM_CYCLE_STEPS = 450 # 280

var grid := []
var sim_position := Vector2(0, 0)
var objects := []

var world: World = null

func initialize(p_world: World):
	world = p_world

	grid.resize(world.grid_size)
	for i in range(world.grid_size):
		grid[i] = []
		grid[i].resize(world.grid_size)
		for j in range(world.grid_size):
			grid[i][j] = GridBlock.air(-10.0)

func add_object(o):
	objects.push_back(o)

func object_interactions():
	for o in objects:
		var grid_position = world.world_to_grid(o.position)
		var dt = object_temperature(o.internal_temperature, grid_position)
		var updated_block = GridBlock.new(o.internal_temperature.celsius + dt,
											o.internal_temperature.conductivity,
											o.internal_temperature.state)
		var grid_block = grid[grid_position.x][grid_position.y]
		o.temperature_interaction(updated_block, grid_block)

func _grid_temperature(a: Vector2, b: Vector2):
	grid[a.x][a.y].celsius += object_temperature(grid[a.x][a.y], b)

func object_temperature(object: GridBlock, grid_position: Vector2) -> float:
	var gridobj = grid[grid_position.x][grid_position.y]
	var dt = gridobj.celsius - object.celsius

	dt *= object.conductivity * gridobj.conductivity

	match [object.state, gridobj.state]:
		[GridBlock.STATE.GAS, GridBlock.STATE.GAS]:
			dt /= GAS_RATE
		[GridBlock.STATE.SOLID, GridBlock.STATE.SOLID]:
			dt /= SOLID_RATE
		_:
			dt /= TRANSITION_RATE

	grid[grid_position.x][grid_position.y].celsius = gridobj.celsius - dt
	return dt

func get_temperature(v: Vector2):
	return grid[v.x][v.y].celsius

func set_block(v: Vector2, grid_material: GridBlock):
	grid[v.x][v.y] = grid_material

func player_interaction(pos: Vector2, internal_temperature: GridBlock):
	var dt = object_temperature(internal_temperature, world.world_to_grid(pos))
	return internal_temperature.celsius + dt

func _simulation_cycle_finished():
	object_interactions()

func serialize():
	var result = []

	for x in world.grid_size:
		for y in world.grid_size:
			result.push_back(grid[x][y].kelvin)

	return var_to_bytes(result)

func deserialize(serialized_data):
	for i in range(serialized_data):
		grid[i % world.grid_size][i / world.grid_size] = serialized_data[i]

func _process(_delta):
	for i in range(SIM_CYCLE_STEPS):
		_grid_temperature(sim_position, Vector2(sim_position.x, sim_position.y + 1))
		_grid_temperature(Vector2(sim_position.x + 1, sim_position.y), sim_position)

		sim_position.x += 1
		if sim_position.x >= world.grid_size - 1:
			sim_position.x = 0
			sim_position.y += 1
		if sim_position.y >= world.grid_size - 1:
			sim_position.y = 0
			_simulation_cycle_finished()
