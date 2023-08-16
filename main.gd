extends Node2D

const Temperature = preload("res://temperature.gd")
const Fire = preload("res://fire.gd")
const World = preload("res://world.gd")
const Player = preload("res://player.gd")
const BigWood = preload("res://big_wood.gd")

var block = preload("res://block.tscn")
var wood = preload("res://wood.tscn")
var fire = preload("res://fire.tscn")
var tree = preload("res://tree.tscn")
var big_wood = preload("res://big_wood.tscn")

var world = World.new(84, 64)

@onready var temperature_control = $TemperatureControl as Temperature
@onready var player = $Player as Player
@onready var temperature_label = $UI/Temperature as Label
@onready var cold_overlay = $UI/Overlay as ColorRect
@onready var block_placeholder = $BlockPlaceholder as ColorRect
@onready var fuel_placeholder = $FuelPlaceholder as ColorRect
@onready var big_wood_placeholder = $BigWoodPlaceholder as ColorRect


func put_wood(where: Vector2):
	if not _test_collision(player.wood_collision_shape.shape, where) \
		and not _cast_ray(player.position, where, [player.get_rid()]):
			var wood_instance = wood.instantiate()
			wood_instance.position = where
			self.add_child(wood_instance)
			player.lose_fuel()

func put_big_wood(where: Vector2):
	var grid_position = world.world_to_grid(where)
	var world_position = world.grid_to_world(grid_position) + Vector2(18, 18)

	if not _test_collision(player.big_wood_collision_shape.shape, world_position) \
		and not _cast_ray(player.position, world_position, [player.get_rid()]):
			var big_wood_instance = big_wood.instantiate()
			big_wood_instance.position = world_position
			big_wood_instance.connect('clicked', _on_tree_clicked)
			self.add_child(big_wood_instance)
			player.lose_big_wood()

func place_block_to_grid(grid_position: Vector2, unbreakable=false):
	var world_position = world.grid_to_world(grid_position) + Vector2(32, 32)

	var block_instance = block.instantiate()
	block_instance.position = world_position
	block_instance.connect('clicked', _on_block_clicked)

	block_instance.breakable = not unbreakable

	self.add_child(block_instance)

	var t = temperature_control.get_temperature(grid_position)
	temperature_control.set_block(grid_position, GridBlock.solid_block(t))

func put_block(where: Vector2):
	var grid_position = world.world_to_grid(where) # + Vector2(32, 32)
	var world_position = world.grid_to_world(grid_position) + Vector2(32, 32)

	if not _test_collision(player.block_collision_shape.shape, world_position) \
		and not _cast_ray(player.position, where, [player.get_rid()]):
			place_block_to_grid(grid_position)
			player.lose_block()

func fire_construct_instance(where: Vector2):
	var fire_instance = fire.instantiate()
	fire_instance.position = where
	fire_instance.initialize(temperature_control, player)
	fire_instance.connect("clicked", _on_fire_clicked)
	return fire_instance

func construct_world(
block_noise: FastNoiseLite,
tree_noise: FastNoiseLite,
rng: RandomNumberGenerator):
	var threshold = 0.25
	var unbreakable_threshold = 0.85

	# initialize fire

	var f_grid_position = world.world_to_grid(player.position) + Vector2(3, 2)
	var f_world_position = world.grid_to_world(f_grid_position)
	var fire_instance = fire_construct_instance(f_world_position)
	self.add_child(fire_instance)

	# initialize player

	# player.connect("died", fire_instance._on_player_died)
	player.put_wood = self.put_wood
	player.put_block = self.put_block
	player.put_big_wood = self.put_big_wood

	# initialize temperature control

	temperature_control.initialize(world)
	temperature_control.add_object(player)
	temperature_control.add_object(fire_instance)

	# place blocks

	var free_blocks = []

	for x in range(world.grid_size):
		for y in range(world.grid_size):
			var block_noise_sample = block_noise.get_noise_2d(x, y)
			var tree_noise_sample = tree_noise.get_noise_2d(x, y)
			var grid_position = Vector2(x, y)
			var world_position = world.grid_to_world(grid_position)

			var positional_value = _area_fn(x, y, unbreakable_threshold + 1.0)
			var k = positional_value + block_noise_sample

			if k > threshold:
				place_block_to_grid(grid_position, k >= unbreakable_threshold)

			elif rng.randf() < 0.025:
				var w = wood.instantiate()
				w.position = world_position + Vector2(32, 32)
				self.add_child(w)

			elif tree_noise_sample > 0.3 and rng.randf() > 0.85:
				var tree_instance = tree.instantiate()
				tree_instance.position = world_position
				tree_instance.connect('clicked', _on_tree_clicked)
				self.add_child(tree_instance)

			else:
				free_blocks.push_back(world_position)

	var idx = rng.randi_range(0, free_blocks.size())
	player.position = free_blocks[idx] + Vector2(32, 32)
	free_blocks.remove_at(idx)

	free_blocks.sort_custom(func (a, b):
		return a.distance_to(player.position) < b.distance_to(player.position)
	)
	fire_instance.position = free_blocks[0] + Vector2(32, 32)

	var _floor = $Floor
	_floor.position = world.grid_to_world(Vector2(0, 0))
	_floor.size = Vector2(world.block_size, world.block_size)
	_floor.scale = Vector2(world.grid_size - 1, world.grid_size - 1)

# print(_floor.get_transform().get_scale(), size * temperature_control.BLOCK_SIZE)

func _area_fn(x: int, y: int, peak: float) -> float:
	var distance = _distance_from_border(world.grid_size, Vector2(x, y))
	var k = 10.0

	return clampf(peak * (1.0 - (distance as float / k as float)), 0.0, peak)

func _distance_from_border(p_size: int, point: Vector2) -> int:
	var top_distance = abs(point.y - p_size)
	var bottom_distance = abs(point.y - 0)
	var left_distance = abs(point.x - 0)
	var right_distance = abs(point.x - p_size)

	return min(top_distance, bottom_distance, left_distance, right_distance)

func _process(_delta):
	var fmt = "Internal temperature: %.1f \u00b0C\nExternal temperature: %.1f \u00b0C"
	var temperature_text = fmt % [player.internal_temperature.celsius, player.external_temperature]
	temperature_label.text = temperature_text

	cold_overlay.color.a = 1.0 - player.freeing_progress()

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.seed = randi()

	var block_noise = FastNoiseLite.new()
	block_noise.seed = rng.randi() # 1336368079
	block_noise.frequency = 0.075

	var tree_noise = FastNoiseLite.new()
	tree_noise.seed = rng.randi()
	tree_noise.frequency = 0.02

	print(block_noise.seed, tree_noise.seed)

	construct_world(block_noise, tree_noise, rng)

	var ui_events = InputMap.action_get_events("ui_accept").map(func (a): return '"%s"' % a.as_text())
	var action_names = "(%s)" % " or ".join(ui_events)
	$UI/Restart.text = "Press %s to restart" % action_names

func _test_collision(p_shape: Shape2D, p_position):
	var world_state = get_world_2d().direct_space_state
	var params = PhysicsShapeQueryParameters2D.new()
	params.collide_with_areas = true
	params.shape = p_shape # p_shape.get_rid()
	params.transform = Transform2D(0.0, p_position)

	var collisions = world_state.intersect_shape(params, 1)
	return not collisions.is_empty()

func _cast_ray(from: Vector2, to: Vector2, exclude=[]):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from, to, 0xffffffff, exclude)
	var result = space_state.intersect_ray(query)
	return not result.is_empty()

func _unhandled_input(event):
	if not player.alive and event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_position = get_global_mouse_position()
		var grid_position = world.world_to_grid(mouse_position)
		var world_position = world.grid_to_world(grid_position)

		var collision_shape = null
		var collision_position = null
		var placeholder = null
		var place_position = null

		match player.carying:
			Player.CARRY_ITEMS.BLOCK:
				collision_shape = player.block_collision_shape.shape
				collision_position = world_position + Vector2(32, 32)
				placeholder = block_placeholder
				place_position = world_position
			Player.CARRY_ITEMS.FUEL:
				collision_shape = player.wood_collision_shape.shape
				collision_position = mouse_position
				placeholder = fuel_placeholder
				place_position = mouse_position - Vector2(8, 8)
			Player.CARRY_ITEMS.BIG_WOOD:
				collision_shape = player.big_wood_collision_shape.shape
				collision_position = mouse_position
				placeholder = big_wood_placeholder
				place_position = world_position + Vector2(18, 18)
			_:
				fuel_placeholder.visible = false
				block_placeholder.visible = false
				big_wood_placeholder.visible = false
				return

		if player.position.distance_to(place_position) < player.REACH \
				and not _test_collision(collision_shape, collision_position) \
				and not _cast_ray(player.position, place_position, [player.get_rid()]):
					placeholder.position = place_position
					placeholder.visible = true
		else:
			placeholder.visible = false

func _on_fire_clicked(sender: Fire, fire_position: Vector2):
	if player.carying == player.CARRY_ITEMS.FUEL \
		and player.position.distance_to(fire_position) < player.REACH \
		and sender.fuel < sender.refuel_limit:
			player.lose_fuel()
			sender.refuel()

func _on_block_clicked(sender, block_position: Vector2):
	if player.position.distance_to(block_position) < player.REACH \
		and player.carying == player.CARRY_ITEMS.NONE \
		and sender.breakable \
		and not _cast_ray(player.position,
											sender.position,
											[player.get_rid(), sender.collision_body.get_rid()]):
			sender.queue_free()
			player.gain_block()

			var grid_position = world.world_to_grid(block_position)
			var t = temperature_control.get_temperature(grid_position)
			temperature_control.set_block(grid_position, GridBlock.air(t))

func _on_tree_clicked(sender, _mouse_position: Vector2):
	if player.carying == Player.CARRY_ITEMS.NONE \
		and player.position.distance_to(sender.position) < player.REACH:
			player.gain_big_wood()
			sender.queue_free()

	elif sender is BigWood and player.carying == Player.CARRY_ITEMS.FUEL:
		var fire_instance = fire_construct_instance(sender.position)
		sender.queue_free()
		self.add_child(fire_instance)
		player.lose_fuel()
		fire_instance.fuel = 0.0
		var grid_position = world.world_to_grid(sender.position)
		fire_instance.internal_temperature.celsius = temperature_control.get_temperature(grid_position)
		temperature_control.add_object(fire_instance)

func _on_player_died():
	$UI/Restart.visible = true
	set_process(false)
	set_physics_process(false)


