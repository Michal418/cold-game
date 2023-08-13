class_name GridMaterial

enum STATE { SOLID, GAS }

var conductivity: float
var state: STATE

func _init(p_conductivity: float, p_state: STATE):
	conductivity = p_conductivity
	state = p_state
