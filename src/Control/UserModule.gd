class_name UserModule
extends ControlModule

func gather_input(_body : Node2D) -> void:
	self.clear_input()
	var moving_actions : Array = ["ctrl_up", "ctrl_down", 
		"ctrl_left", "ctrl_right"]
	for i in range(moving_actions.size()):
		if Input.is_action_just_pressed(moving_actions[i]):
			moving[i] = true
			just_move[i] = true
			move_strength[i] = Input.get_action_strength(moving_actions[i])
		elif Input.is_action_pressed(moving_actions[i]):
			moving[i] = true
			move_strength[i] = Input.get_action_strength(moving_actions[i])
	#
	if Input.is_action_just_pressed("ctrl_jump"):
		jumping = true
		just_jump = true
	elif Input.is_action_pressed("ctrl_jump"):
		jumping = true
	#
	if Input.is_action_just_pressed("ctrl_fire"):
		firing = true
		just_fire = true
	elif Input.is_action_pressed("ctrl_fire"):
		firing = true

func get_angle_from(node : CanvasItem = null) -> BoolFloatTuple:
	var handled = false
	var rtrn = BoolFloatTuple.new()
	var ctrl = InputInfo.get_current_control()
	if ctrl == InputInfo.Controller.JOYSTICK:
		handled = true
		var index = InputInfo.get_last_joystick()
		var look = Vector2(
			Input.get_joy_axis(index, JOY_AXIS_2),
			Input.get_joy_axis(index, JOY_AXIS_3))
		if (look.length() >= InputInfo.DEADZONE): 
			rtrn.b = true
			rtrn.f = look.angle()
	elif ctrl == InputInfo.Controller.MOUSE_KEYBOARD:
		handled = true
		if node != null: 
			rtrn.b = true
			rtrn.f = node.get_local_mouse_position().angle()
		else: print("Node required for angle in UserModule")
	if !handled: print("Unhandled control type in UserModule")
	return rtrn
	
