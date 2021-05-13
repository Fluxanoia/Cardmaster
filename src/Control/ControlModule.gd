class_name ControlModule
extends Resource

var restrict : Array = []
var restrict_length : int = 0
var allowlist : bool = false

var move_strength : Array = [1, 1, 1, 1]
var moving        : Array = [false, false, false, false]
var just_move     : Array = [false, false, false, false]

var jumping   : bool = false
var just_jump : bool = false

var firing    : bool = false
var just_fire : bool = false

var angle_position = null
var angle : float = 0

func tick() -> void:
	if restrict_length > 0:
		restrict_length -= 1
		if restrict_length == 0:
			restrict = []

func has_input(input : int, just : bool = false) -> bool:
	if restrict_length > 0:
		var i = input in restrict
		if (allowlist && not i) || (not allowlist && i):
			return false
	if input >= 0 && input < 4:
		return just_move[input] if just else moving[input]
	if input == InputInfo.Inputs.JUMP:
		return just_jump if just else jumping
	if input == InputInfo.Inputs.FIRE:
		return just_fire if just else firing
	push_error("Unknown input type: " + str(input) + ".")
	return false
	
func has_any_input(input : Array) -> bool:
	for i in input:
		if self.has_input(i): return true
	return false

func clear_input() -> void:
	move_strength = [1, 1, 1, 1]
	for i in range(moving.size()): moving[i] = false
	for i in range(just_move.size()): just_move[i] = false
	jumping = false
	just_jump = false
	firing = false
	just_fire = false

func gather_input(_body : Node2D) -> void:
	pass

func get_moving_strength() -> Array:
	return move_strength

	
func get_angle_from(_node : CanvasItem = null) -> BoolFloatTuple:
	return BoolFloatTuple.new()
	
func set_restrictions(r : Array, length : int, allow : bool):
	self.restrict = r
	self.restrict_length = length
	self.allowlist = allow

func clear_restrictions():
	self.restrict = []
	self.restrict_length = 0
	self.allowlist = false

##################
	
func has_moved() -> bool:
	var a = jumping
	for i in range(4):
		if a: break
		a = a || moving[i]
	return a
	
func has_actioned() -> bool:
	return has_moved() || firing
