class_name GridBlock

enum STATE { SOLID, GAS }

var _temperature: float
var conductivity: float
var state: STATE

static func air(p_temperature: float):
	return GridBlock.new(p_temperature, 0.95, STATE.GAS)

static func solid_block(p_temperature: float):
	return GridBlock.new(p_temperature, 0.005, STATE.SOLID)

func serialize():
	return {
		"celsius": get_celsius(),
		"conductivity": conductivity,
		"state": state
	}
	
static func deserialize(serialized_data):
	return GridBlock.new(serialized_data["celsius"], serialized_data["conductivity"], serialized_data["state"])

func get_kelvin() -> float:
	return _temperature

func get_celsius() -> float:
	return _temperature - 273.16

func get_fahrenheit() -> float:
	return (9.0 / 5.0) * _temperature - 459.67

func set_kelvin(value):
	_temperature = value

func set_celsius(value):
	_temperature = value + 273.16

func set_fahrenheit(value):
	_temperature = (value + 459.67) * (5.0 / 9.0)

func _get(property):
	match property:
		"kelvin":
			return get_kelvin()
		"celsius":
			return get_celsius()
		"fahrenheit":
			return get_fahrenheit()

func _set(property, value):
	match property:
		"kelvin":
			set_kelvin(value)
			return true
		"celsius":
			set_celsius(value)
			return true
		"fahrenheit":
			set_fahrenheit(value)
			return true

func _get_property_list():
	return [
		{ "name": "kelvin", "type": TYPE_FLOAT },
		{ "name": "celsius", "type": TYPE_FLOAT },
		{ "name": "fahrenheit", "type": TYPE_FLOAT }
	]

func _init(p_temperature, p_conductivity, p_state):
	assert(p_conductivity >= 0.0 and p_conductivity <= 1.0)

	set_celsius(p_temperature)
	conductivity = p_conductivity
	state = p_state

