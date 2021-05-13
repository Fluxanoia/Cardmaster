class_name Entity
extends KinematicBody2D

#################
### Constants ###
#################

# The signals to connect to for the detect_area
const AREA_SIGNALS = [
	"body_entered", "body_exited",
	"area_entered", "area_exited"
]

# The speed at which the value is sent to zero
const MIN_SPEED = 1

# The step of code generated animations
const ANIM_STEP : float = 0.01
# The name of the temporary animation
const ANIM_TEMP : String = "temp"

# If the entities should draw their hitbox
const DRAW_HITBOX = false
	
###############
### Signals ###
###############

# Emitted before a physics stage is finalised
signal finalise_physics(delta)
# Emitted after a strike has been finalised
signal struck(info)

#################
### Variables ###
#################

# The physics parameters
enum PhysicsType { NONE, GRAVITY, ZERO_GRAVITY }
var zerog_params : ZeroGParams
var gravity_params : GravityParams
var physics_type : int = PhysicsType.NONE
# The jump timer for gravity based physics
var jump_timer : Timer = null

# The entities scale
var entity_scale : Vector2 = Vector2(1, 1)

# Whether the entity landed in the last physics cycle
var just_landed : bool = false

# The collision shapes
var collision_shape : CollisionShape2D = null
var detection_shape : CollisionShape2D = null
# The collision detection area
var detect_area : Area2D = null
# Whether this object can strike
var passive : bool = true
# The strike information of this object
var strike_info : StrikeInfo
# The exception objects
var exceptions : Array = []

# The current velocity
var velocity : Vector2 = Vector2(0, 0)
# The knockback resistance
var knockback_resist = 1

# Whether the entity should currently be on
# the temp animation
var use_temp_animation : bool = false
# The inputs which cancel the temporary animation
var temp_anim_cancels  : Array = []
# Whether the look direction should be locked
var lock_direction : bool = false
# The locked look direction
var locked_direction = null

# The colour modulate tween
var mod_tween : Tween = null

# The number of physics frames the drop thru layer is ignored
# for after a drop thru button press
const DROP_THRU_GRACE = 5
var dropping_thru = 0

# The control type
var module : ControlModule
export (int) var module_code : int

# Animation properties
var sprite        : Sprite = null
var sprite_frames : SpriteFrames = null
var current_anim  : String = ""
var anim_loop     : bool = true 
var anim_speed    : int = -1
var anim_delta    : int = 0
var anim_index    : int = 0

######################
### Initialisation ###
######################

func entity_construct(cs : Shape2D, cso : Vector2, 
		ds : Shape2D, dso : Vector2) -> void:
	self.switch_physics(physics_type)
	self._configure_collision_shape(cs, cso)
	self._configure_detection_shape(ds, dso)
	module = EntityInfo.get_control_module(module_code)
	strike_info = StrikeInfo.new()
	strike_info.source = weakref(self)
	if sprite != null: sprite.set_scale(entity_scale)
	
func entity_prepare() -> void:
	if detect_area != null:
		for s in AREA_SIGNALS: 
			Globals.handle_error(detect_area.connect(s, self, s))
	
var __constructed = false 
func _ready() -> void:
	if not __constructed && self.has_method("construct"):
		self.call("construct")
	if self.has_method("prepare"): self.call("prepare")
	
#####################
### Configuration ###
#####################
	
func _configure_collision_shape(shape : Shape2D,
		offset : Vector2 = Vector2()) -> void:
	if shape == null: return
	if collision_shape == null: 
		collision_shape = CollisionShape2D.new()
		self.add_child(collision_shape)
	collision_shape.set_shape(shape)
	collision_shape.set_position(offset * entity_scale)
	collision_shape.set_scale(entity_scale)
	
func _configure_detection_shape(shape : Shape2D,
		offset : Vector2 = Vector2()) -> void:
	if shape == null: return
	if detect_area == null:
		detect_area = Area2D.new()
		detection_shape = CollisionShape2D.new()
		detect_area.add_child(detection_shape)
		self.add_child(detect_area)
	detection_shape.set_shape(shape)
	detection_shape.set_position(offset * entity_scale)
	detection_shape.set_scale(entity_scale)

func switch_physics(type : int) -> void:
	if (type == PhysicsType.NONE):
		physics_type = type
		return
	if (type == PhysicsType.GRAVITY):
		gravity_params = GravityParams.new()
		physics_type = type
		if (jump_timer == null):
			jump_timer = Timer.new()
			jump_timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
			jump_timer.set_one_shot(true)
			self.add_child(jump_timer)
		jump_timer.set_wait_time(gravity_params.JUMP_MAX_TIME)
		self.set_collision_mask(0)
		self.set_collision_mask_bit(CollisionInfo.MAIN_COLLISION_BIT, true)
		self.set_collision_mask_bit(CollisionInfo.DROPTHRU_COLLISION_BIT, true)
		return
	if (type == PhysicsType.ZERO_GRAVITY):
		zerog_params = ZeroGParams.new()
		physics_type = type
		self.set_collision_mask(0)
		self.set_collision_mask_bit(CollisionInfo.MAIN_COLLISION_BIT, true)
		return
	push_error("Invalid physics type.")

###############
### Physics ###
###############

func process_physics(delta : float, take_input : bool = true) -> void:
	# Take input
	module.tick()
	if take_input: 
		module.gather_input(self)
	else: module.clear_input()
	# Handle intersections
	Globals.remove_instances_in(exceptions, null, true)
	self.handle_intersections()
	# Physics
	if (physics_type == PhysicsType.GRAVITY):
		__gravity_physics(delta)
	if (physics_type == PhysicsType.ZERO_GRAVITY):
		__zero_g_physics(delta)
	# Animations
	if sprite_frames != null && sprite_frames.has_animation(current_anim):
		if anim_delta == anim_speed: 
			progress_animation()
		anim_delta += 1
	if use_temp_animation && module.has_any_input(temp_anim_cancels): 
		stop_temp_animation()
	self.handle_animation()

func __gravity_physics(delta : float) -> void:
	if velocity.y + Globals.get_gravity() < gravity_params.TERMINAL_VELOCITY:
		if velocity.y > gravity_params.TERMINAL_VELOCITY:
			velocity.y = gravity_params.TERMINAL_VELOCITY
		elif velocity.y < gravity_params.TERMINAL_VELOCITY:
			velocity.y *= gravity_params.EXTREME_AIR_DECAY
	else: velocity.y += Globals.get_gravity()
	if velocity.y > gravity_params.MAX_FLY: 
		velocity.y *= gravity_params.EXTREME_AIR_DECAY
	# Masking
	if module.has_input(InputInfo.Inputs.MOVE_DOWN):
		dropping_thru = DROP_THRU_GRACE
	elif velocity.y < 0: dropping_thru = 1
	elif dropping_thru > 0: dropping_thru -= 1
	self.set_collision_mask_bit(CollisionInfo.DROPTHRU_COLLISION_BIT,
		dropping_thru == 0)
	# Horizontal movement
	var left = module.has_input(InputInfo.Inputs.MOVE_LEFT)
	var right = module.has_input(InputInfo.Inputs.MOVE_RIGHT)
	var accel : float = 0
	# Get the acceleration
	if left: accel -= gravity_params.ACCELERATION
	if right: accel += gravity_params.ACCELERATION
	# Get the max speed
	var min_str = 1
	var move_str = module.get_moving_strength()
	var speed_max = gravity_params.MAX_SPEED
	for i in [InputInfo.Inputs.MOVE_LEFT, InputInfo.Inputs.MOVE_RIGHT]:
		if module.has_input(i) && move_str[i] < min_str: 
			min_str = move_str[i]
	speed_max *= min_str
	# If we have no resultant movement and the speed isn't extreme,
	# decay the horizontal movement
	if abs(velocity.x) <= speed_max && accel == 0:
		if is_on_floor():
			velocity.x *= gravity_params.GROUND_SPEED_DECAY
		else: velocity.x *= gravity_params.AIR_SPEED_DECAY
	var extreme_x = abs(velocity.x + accel) > speed_max
	# If our end velocity is extreme and we are heading to increase the
	# extremity...
	if extreme_x && abs(velocity.x + accel) >= abs(velocity.x):
		# If we're only just becoming extreme, cap the speed
		if abs(velocity.x) < speed_max:
			velocity.x = sign(velocity.x) * speed_max
		# If our initial velocity was extreme, decay the extremity
		elif abs(velocity.x) > speed_max:
			if is_on_floor():
				velocity.x *= gravity_params.EXTREME_GROUND_DECAY
			else: velocity.x *= gravity_params.EXTREME_AIR_DECAY
			if abs(velocity.x) < speed_max:
				velocity.x = sign(velocity.x) * speed_max
	# If the end velocity isn't extreme or we are reducing the extremity,
	# allow acceleration
	else: velocity.x += accel
	if abs(velocity.x) < MIN_SPEED: velocity.x = 0
	# Vertical movement
	# If we are on the floor, reset the jump timer
	# and/or start a jump if possible
	if is_on_floor():
		if !jump_timer.is_stopped(): jump_timer.stop()
		if module.has_input(InputInfo.Inputs.JUMP, true):
			jump_timer.start()
	# If the jump timer is running but we've let go of jump
	# stop the timer
	if !jump_timer.is_stopped() && !module.has_input(InputInfo.Inputs.JUMP):
		jump_timer.stop()
	# If the jump timer is running but we've hit a ceiling,
	# stop the timer
	if !jump_timer.is_stopped() && is_on_ceiling():
		jump_timer.stop()
	# If the jump timer is running and we are pressing jump, continue
	# the jump
	if !jump_timer.is_stopped() && module.has_input(InputInfo.Inputs.JUMP):
		if velocity.y > gravity_params.JUMP_STRENGTH:
			velocity.y = gravity_params.JUMP_STRENGTH
	# Emit finalise signal
	self.emit_signal("finalise_physics", delta)
	# Check if we are grounded
	var was_on_floor = is_on_floor()
	# Update velocity
	velocity = move_and_slide(velocity, Globals.UP)
	# Check for landing
	just_landed = not was_on_floor && is_on_floor()
	
func __zero_g_physics(delta : float) -> void:
	# Get the resultant acceleration
	var resultant = Vector2(0, 0)
	var moving = false
	for i in range(4):
		if not module.has_input(i): continue
		resultant += Globals.get_direction(i)
		moving = true
	if resultant.length() == 0: 
		var angle = module.get_angle_from(self)
		if angle.b: resultant = Globals.RIGHT.rotated(angle.f)
	elif resultant.length() != 0: resultant = resultant.normalized()
	resultant *= zerog_params.ACCELERATION
	# Get the max speed
	var speed_max = zerog_params.MAX_SPEED
	if moving:	
		var move_str = module.get_moving_strength()
		var x = Globals.Direction.LEFT 
		if resultant.x > 0: x = Globals.Direction.RIGHT
		x = move_str[x] if resultant.x != 0 else 0
		var y = Globals.Direction.UP 
		if resultant.y > 0: y = Globals.Direction.DOWN
		y = move_str[y] if resultant.y != 0 else 0
		speed_max *= clamp(Vector2(x, y).length(), 0, 1)
	# Record the velocity strength before and after
	var ilen = velocity.length()
	velocity += resultant
	var elen = velocity.length()
	# Acclerate
	if elen > speed_max:
		if ilen <= speed_max:
			velocity = velocity.normalized() * speed_max
		elif ilen > speed_max:
			var target = ilen * zerog_params.EXTREME_DECAY
			if elen < target: target = elen
			velocity = velocity.normalized() * target
	elif resultant.length() == 0: 
		velocity *= zerog_params.SPEED_DECAY
	else: velocity += resultant
	if velocity.length() < MIN_SPEED: velocity = Vector2(0, 0)
	# Emit finalise signal
	self.emit_signal("finalise_physics", delta)
	# Update velocity
	velocity = move_and_slide(velocity, Globals.UP)
	
# Returns the side on which a wall was collided with in the
# last collision pass
func get_which_wall_collided() -> int:
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision.normal.x > 0:
			return Globals.Side.LEFT
		elif collision.normal.x < 0:
			return Globals.Side.RIGHT
	return 0
	
func move_to(pos : Vector2) -> void:
	self.set_position(pos)
	
#################
### Collision ###
#################

func _draw() -> void:
	if DRAW_HITBOX: 
		collision_shape.get_shape().draw(get_canvas_item(), Color.red)

func gather_intersections() -> Array:
	var out = []
	var arr = detect_area.get_overlapping_bodies()
	for a in arr: if self.can_collide(a): out.push_back(a)
	return out

func handle_intersections() -> void:
	pass
	
# Strikes the entity with some information
func strike(info : StrikeInfo) -> void:
	if info == null: return
	self.knockback(info)
	if info.source != null && info.source.get_ref() != null:
		var src = info.source.get_ref()
		if src.has_method("has_struck"): src.has_struck()
		if info.oneshot: self.add_exception(src)
	self.emit_signal("struck")
	
# Knockbacks the entity with some information
func knockback(info : StrikeInfo) -> void:
	if info == null: return
	var dir = Globals.RIGHT
	if info.knockback_angle_override:
		dir = Globals.RIGHT.rotated(info.knockback_angle)
	elif info.source != null && info.source.get_ref() != null:
		var src = info.source.get_ref()
		if src.has_method("get_position"):
			dir = self.position - src.get_position()
			if dir.x <= 0:
				dir = Globals.LEFT + Globals.UP
			else: dir = Globals.RIGHT + Globals.UP
	velocity = dir.normalized() * info.knockback * knockback_resist

# Called when this entity has struck another
func has_struck() -> void:
	pass
	
# Called when this entity dies
func dead() -> void:
	queue_free()
	
# Checks whether we can collided with an entity
func can_collide(body : Node) -> bool:
	if body == self: 
		return false
	if self.has_exception(body): 
		return false
	if body.has_method("get_strike_info"):
		var info = body.get_strike_info()
		if info != null && info.source != null:
			if self.has_exception(info.source.get_ref()): return false
	if body.has_method("has_exception") && body.has_exception(self): 
		return false
	if EntityInfo.share_sister_groups(self, body):
		return false
	return true
	
func body_entered(_body : Node) -> void:
	pass
	
func body_exited(_body : Node) -> void:
	pass
	
func area_entered(_body : Node) -> void:
	pass
	
func area_exited(_body : Node) -> void:
	pass
	
func is_passive() -> bool:
	return passive

func get_strike_info() -> StrikeInfo:
	return strike_info

func set_strike_info(si : StrikeInfo) -> void:
	strike_info = si
	
##################
### Animations ###
##################

func modulate_tween(start : Color, end : Color, d : float,
		t : int = Tween.TRANS_EXPO, e : int = Tween.EASE_OUT):
	if mod_tween == null:
		mod_tween = Tween.new()
		self.add_child(mod_tween)
	Globals.error_on_false(mod_tween.remove_all())
	Globals.error_on_false(mod_tween.interpolate_property(sprite,
		"modulate", start, end, d, t, e))
	Globals.error_on_false(mod_tween.start())

func handle_animation() -> void:
	pass

func is_using_temp_animation(anim : AnimationPlayer) -> bool:
	if use_temp_animation:
		if anim.get_assigned_animation() != ANIM_TEMP:
			anim.play(ANIM_TEMP)
			return true
		elif not anim.is_playing():
			stop_temp_animation()
		else: return true
	return false

func has_direction_locked() -> bool:
	return lock_direction

func get_locked_direction():
	return locked_direction

func set_animation(anim : String, loop : bool, speed : int = -1,
		start_index : int = 0) -> void:
	if not __verify_anim(anim): return
	if current_anim == anim: return
	current_anim = anim
	anim_loop = loop
	anim_delta = 0
	anim_index = start_index
	anim_speed = speed
	sprite.set_texture(sprite_frames.get_frame(current_anim, anim_index))
		
func progress_animation() -> void:
	if not __verify_anim(): return
	var count = sprite_frames.get_frame_count(current_anim)
	if count == 0: return
	anim_delta = 0
	anim_index += 1
	if anim_index == count: 
		if anim_loop: 
			anim_index = 0
		else: 
			anim_index -= 1
			anim_speed = -1
	sprite.set_texture(sprite_frames.get_frame(current_anim, anim_index))
		
func stop_temp_animation() -> void:
	use_temp_animation = false
	temp_anim_cancels = []
	lock_direction = false
	locked_direction = null
		
func __verify_anim(a : String = current_anim) -> bool:
	if sprite_frames == null: 
		push_error("No SpriteFrames on Entity.")
		return false
	if not sprite_frames.has_animation(a):
		push_error("No such animation " + a + " on Entity.")
		return false
	return true
	
##################
### Exceptions ###
##################

func get_exceptions() -> Array:
	return exceptions
	
func has_exception(obj : Object) -> bool:
	if obj == null: return false
	for e in exceptions:
		if e == null: continue
		if e.get_ref() == obj: return true
	return false
	
func add_exception(obj : Object) -> void:
	if obj == null: return
	exceptions.push_back(weakref(obj))
	
func remove_exception(obj : Object) -> void:
	var index = 0
	while index < exceptions.size():
		if exceptions[index] == null || exceptions[index].get_ref() == obj:
			exceptions.remove(index)
		else: index += 1

#######################
### Getters/Setters ###
#######################

func get_type() -> int:
	return -1

func get_module() -> ControlModule:
	return module

func get_module_code() -> int:
	return module_code
	
func set_module_code(code : int) -> void:
	module_code = code
