class_name ZombieModule
extends ControlModule

const MIN_INTEREST         : float = 250.0
const INTEREST_VARIABILITY : float = 450.0

const MIN_PATIENCE        : int = 2
const PATIENCE_VARIABLITY : int = 4

const MIN_DISINTEREST        : int = 1
const DISINTEREST_VARIABLITY : int = 4
const DISINTEREST_CUTOFF     : float = 200.0

const WANDER_DEADZONE : float = 0.25

const ATTACK_RANGE : float = 150.0

var interest_range : float

var patience     : int = 0
var disinterest  : int = 0
var focusing     : bool = false
var last_dist    : float
var current_dist : float

var noise : OpenSimplexNoise = OpenSimplexNoise.new()

func _init() -> void:
	noise.seed = randi()
	noise.period = 5 + randi() % 5
	interest_range = MIN_INTEREST + randf() * INTEREST_VARIABILITY

func gather_input(body : Node2D) -> void:
	var old_moving = moving
	var old_jumping = jumping
	var old_firing = firing
	self.clear_input()
	var focus = get_focus_from(body)
	if focus == null:
		var dir = noise.get_noise_1d(OS.get_ticks_msec() / 1000.0)
		moving[Globals.Direction.LEFT] = dir < -WANDER_DEADZONE
		moving[Globals.Direction.RIGHT] = dir > WANDER_DEADZONE
		move_strength = [0.5, 0.5, 0.5, 0.5]
		jumping = body is KinematicBody2D && body.is_on_wall()
	else:
		var vector_to = focus.get_position()
		vector_to.x -= body.get_position().x
		vector_to.y -= body.get_position().y
		moving[Globals.Direction.LEFT]  = vector_to.x < 0
		moving[Globals.Direction.RIGHT] = vector_to.x > 0
		jumping = vector_to.y < 0
		firing = current_dist < ATTACK_RANGE
	if body is KinematicBody2D && body.is_on_floor() && jumping:
		just_jump = true
	if !old_moving[Globals.Direction.LEFT]:
		just_move[Globals.Direction.LEFT] = moving[Globals.Direction.LEFT]
	if !old_moving[Globals.Direction.RIGHT]:
		just_move[Globals.Direction.RIGHT] = moving[Globals.Direction.RIGHT]
	if !old_jumping: just_jump = jumping
	if !old_firing: just_fire = firing
	
func get_focus_from(body : Node) -> Node2D:
	# Get the closest player to the entity
	var dist     : float = 0.0
	var new_dist : float = 0.0
	var player   : Node2D = null
	for p in body.get_tree().get_nodes_in_group(EntityInfo.PLAYER_GROUP):
		if not (p is Node2D): continue
		new_dist = p.get_position().distance_to(body.get_position())
		if player == null:
			player = p
			dist = new_dist
		elif new_dist < dist:
			player = p
			dist = new_dist
	# If there are no players, return null
	if player == null: return null
	# If the distance is outside of our interest, return null
	# and reset values
	if dist > interest_range:
		focusing = false
		patience = 0
		disinterest = 0
		return null
	# If we are disinterested, check if the focus is close enough
	# to ignore it - also, decrement the disinterest
	if disinterest > 0:
		if dist < DISINTEREST_CUTOFF:
			disinterest = 0
		else: 
			disinterest -= 0
			return null
	# If we aren't focusing prepare focus and patience
	if !focusing:
		focusing = true
		last_dist = dist
		refresh_patience()
	# If we are focusing, refresh patience if we're getting closer,
	# decrement it otherwise - also, become disinterested if necessary
	elif focusing:
		if dist < last_dist || dist < DISINTEREST_CUTOFF: 
			refresh_patience()
			last_dist = dist
		else: patience -= 1
		if patience <= 0:
			focusing = false
			refresh_disinterest()
			return null
	current_dist = dist
	return player
	
func refresh_patience() -> void:
	patience = MIN_PATIENCE + (randi() % (PATIENCE_VARIABLITY + 1))
	patience *= Globals.get_physics_fps()
	
func refresh_disinterest() -> void:
	disinterest = MIN_DISINTEREST + (randi() % (DISINTEREST_VARIABLITY + 1))
	disinterest *= Globals.get_physics_fps()
