class_name Actor
extends Entity

#################
### Constants ###
#################

# The default health bar textures
const DEFAULT_HP_UNDER = "res://images/ui/hp_under.png"
const DEFAULT_HP_PROG = "res://images/ui/hp_progress.png"
const DEFAULT_HP_OVER = "res://images/ui/hp_over.png"

#################
### Variables ###
#################

# The health value
var hp : float = 100
# The max health value
var max_hp : float = 100
# The health bar dimensions
var health_dim : Rect2 = Rect2(0, 40, 80, 16)
# The health bar images
var health_under_texture : Texture = null
var health_progress_texture : Texture = null
var health_over_texture : Texture = null
# The health bar
var health_bar : TextureProgress = null

# Whether the entity is dead
var dead : bool = false
# Whether the entity is about to be dead
var dying : bool = false

# The current remaining i-frames
var i_frames : int = 0
# The length of i-frames
var	i_frames_length : int = 0

# The current action on the actor
var action : Action = null
# The length of the action
var action_length : int = 0
	
#####################
### Configuration ###
#####################
	
func actor_construct(cs : Shape2D, cso : Vector2, 
		ds : Shape2D, dso : Vector2, auto_health_bar : bool) -> void:
	self.entity_construct(cs, cso, ds, dso)
	self._configure_health_bar(auto_health_bar)
	sprite.set_material(Globals.get_outline_shader(1, Color.black))
	
func actor_prepare() -> void:
	Globals.handle_error(self.connect("finalise_physics", self, 
		"__tick_action"))
	Globals.handle_error(self.connect("struck", self, "actor_struck"))
	self.entity_prepare()
	
func _configure_health_bar(auto_image : bool = true) -> void:
	if health_bar != null: return
	health_bar = TextureProgress.new()
	health_bar.rect_position = Vector2(-health_dim.size.x / 2, 
		health_dim.position.y)
	health_bar.rect_size = health_dim.size
	if auto_image:
		health_under_texture = load(DEFAULT_HP_UNDER)
		health_progress_texture = load(DEFAULT_HP_PROG)
		health_over_texture = load(DEFAULT_HP_OVER)
	health_bar.set_under_texture(health_under_texture)
	health_bar.set_progress_texture(health_progress_texture)
	health_bar.set_over_texture(health_over_texture)
	health_bar.set_max(max_hp)
	health_bar.set_value(hp)
	self.add_child(health_bar)
	
###############
### Actions ###
###############

func process_action(fireable : Object = null) -> bool:
	var can_cancel = action == null
	can_cancel = can_cancel || (action != null 
		&& InputInfo.Inputs.FIRE in action.cancels)
	if module.has_input(InputInfo.Inputs.FIRE, true):
		if fireable != null && fireable.has_method("fire"):
			self.__set_action(fireable.fire())
			return action != null
	return false
	
func actor_struck(info : StrikeInfo) -> void:
	if action != null && info.stops && action.stoppable: 
		self.cancel_action()
		
func action_cancelled() -> void:
	pass
	
func action_finished() -> void:
	pass
	
func cancel_action() -> void:
	self.__set_action(null)
		
func __set_action(a : Action) -> void:
	if action != null:
		self.__action_callback("cancelled")
		module.clear_restrictions()
		self.stop_temp_animation()
		self.handle_animation()
		self.action_cancelled()
	action = a
	if action == null:
		action_length = 0
	else:
		action_length = action.length
		temp_anim_cancels = action.anim_cancels
		lock_direction = action.lock_direction
		locked_direction = action.locked_direction
		module.set_restrictions(action.restrict, 
			action.restrict_length, action.allowlist)
		if action.self_strike != null: self.strike(action.self_strike)
		
func __tick_action(_delta : float) -> void:
	if action != null:
		if module.has_any_input(action.cancels):
			self.cancel_action()
			if action == null: return
		if action_length < 0: 
			self.__action_callback("finished")
			self.action_finished()
			action = null
			return
		if (action.length - action_length) in action.callback_frames: 
			self.__action_callback("callback")
		action_length -= 1

func __action_callback(method : String) -> void:
	if action == null: return
	if action.callback == null: return
	if action.callback.get_ref() == null: return
	var cb = action.callback.get_ref()
	if cb.has_method(method): cb.call(method)

##################
### Collisions ###
##################
	
func handle_intersections() -> void:
	# Progress i-frames
	if i_frames > 0: 
		i_frames -= 1
		return
	# Check if there's no intersections
	var all = gather_intersections()
	if all.size() == 0: return
	# Gather the relevant intersections
	var intersections = []
	for i in all:
		if i.has_method("get_position") && i.has_method("is_passive"):
			if i.is_passive(): continue
		else: continue
		intersections.push_back(i)
	# Iterate through the intersections, processing
	var striker
	while intersections.size() > 0:
		striker = randi() % intersections.size()
		if !intersections[striker].has_method("get_strike_info"):
			intersections.remove(striker)
			continue
		self.strike(intersections[striker].get_strike_info())
		return
	
# Strike the actor with some information
func strike(info : StrikeInfo) -> void:
	if info == null: return
	self.set_health(hp - info.damage)
	if info.damage > 0: 
		self.modulate_tween(Color(1, 0, 0, 1), Color(1, 1, 1, 1), 1)
		i_frames = i_frames_length
	self.knockback(info)
	if info.source != null && info.source.get_ref() != null:
		var src = info.source.get_ref()
		if src.has_method("has_struck"): src.has_struck()
		if info.oneshot: self.add_exception(src)
	self.emit_signal("struck", info)
	
##############
### Health ###
##############

func set_health(value : float) -> void:
	hp = value
	if hp > max_hp: hp = max_hp
	if hp < 0: hp = 0
	health_bar.set_value(hp)
	if hp == 0: dead()
	
func set_max_health(value : float) -> void:
	max_hp = value
	if max_hp < 0: max_hp = 0
	health_bar.set_max(max_hp)
	
func set_dead(d : bool) -> void:
	self.dead = d
	
func is_dead() -> bool:
	return self.dead
	
#######################
### Getters/Setters ###
#######################

func get_type() -> int:
	return EntityInfo.EntityType.ACTOR

func get_id() -> int:
	return -1
