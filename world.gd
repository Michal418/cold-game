extends RefCounted

var grid_size: int
var block_size: int

func _init(p_grid_size: int, p_block_size: int):
	grid_size = p_grid_size
	block_size = p_block_size

func world_to_grid(v: Vector2) -> Vector2:
	var result = v / block_size
	result = result.floor()
	return result
	
func grid_to_world(v: Vector2) -> Vector2:
	return v * block_size
