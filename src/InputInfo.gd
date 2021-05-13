extends Node

# The enum of different controller types
enum Controller { MOUSE_KEYBOARD, JOYSTICK }
# The generic deadzone for joysticks
const DEADZONE : float = 0.5

# The type of inputs
enum Inputs { MOVE_UP, MOVE_DOWN, MOVE_LEFT,
	MOVE_RIGHT, JUMP, FIRE }
const INPUTS_COUNT = 6

#############
### Input ###
#############

func get_all_inputs() -> Array:
	return range(INPUTS_COUNT)

# The last used joystick
var last_joystick   : int = -1
# The current Controller being used
var current_control : int = Controller.MOUSE_KEYBOARD

# Keep track of the last input device used
func _input(event : InputEvent) -> void:
	if event is InputEventJoypadButton:
		last_joystick = event.device
		current_control = Controller.JOYSTICK
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if event is InputEventJoypadMotion:
		if abs(event.get_axis_value()) >= DEADZONE:
			last_joystick = event.device
			current_control = Controller.JOYSTICK
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if event is InputEventMouseMotion:
		if (event.get_relative().length() >= DEADZONE):
			current_control = Controller.MOUSE_KEYBOARD
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if (event is InputEventKey) or (event is InputEventMouseButton):
		current_control = Controller.MOUSE_KEYBOARD
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func get_current_control() -> int:
	return current_control
	
func get_last_joystick() -> int:
	return last_joystick
	
