extends Node

# Generic enums and constants for directions
enum Side       { LEFT = -1, RIGHT = 1 }
enum Direction  { UP, DOWN, LEFT, RIGHT }
const UP    : Vector2 = Vector2(0, -1)
const DOWN  : Vector2 = Vector2(0, 1)
const LEFT  : Vector2 = Vector2(-1, 0)
const RIGHT : Vector2 = Vector2(1, 0)

# Shaders
const SHADER_OUTLINE = preload("res://gres/outline.shader")

signal screen_shake(intensity, duration, trans, easing)

######################
### Initialisation ###
######################

# Randomise the RNG
func _init() -> void: randomize()

###############
### Helpers ###
###############

# Return the unit vector direction corresponding to the values 
# of the Direction enum
func get_direction(dir : int) -> Vector2:
	if dir == Direction.UP: return UP
	if dir == Direction.DOWN: return DOWN
	if dir == Direction.LEFT: return LEFT
	if dir == Direction.RIGHT: return RIGHT
	push_error("Unknown direction: " + str(dir))
	return Vector2(0, 0)
	
# Remove instances in an array of some object (all or just one instance)
func remove_instances_in(array : Array, r, all : bool) -> void:
	var index = 0
	while index < array.size():
		if array[index] == r:
			array.remove(index)
			if !all: return
		else: index += 1
		
func screen_shake(intensity : float, duration : float, 
		trans : int = Tween.TRANS_EXPO, easing : int = Tween.EASE_OUT):
	self.emit_signal("screen_shake", intensity, duration, trans, easing)
	
########################
### Project Settings ###
########################

# Return the physics frame rate
func get_physics_fps() -> int:
	return ProjectSettings.get_setting("physics/common/physics_fps")
# Return the gravity
func get_gravity() -> float:
	return ProjectSettings.get_setting("physics/2d/default_gravity")
	
###############
### Shaders ###
###############

# Returns an outline shader
func get_outline_shader(width : float, 
		color : Color = Color.black) -> ShaderMaterial:
	var material = ShaderMaterial.new()
	material.set_shader(SHADER_OUTLINE)
	material.set_shader_param("width", width)
	material.set_shader_param("outline_color", color)
	return material
	
##############
### Errors ###
##############

# Handle the built-in Error type
func handle_error(err : int) -> void:
	if err == 0: return
	push_error("Error, code: " + str(err))
	
# Push an error on a false input
func error_on_false(err : bool) -> void:
	if not err: push_error("Error, false.")
