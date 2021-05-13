class_name Attack
extends Resource

var sender : WeakRef = null
var parent : WeakRef = null

var at_sender : bool = false
var position : Vector2 = Vector2()
var offset : Vector2 = Vector2()
var flip_h : bool = false
var flip_v : bool = false

var action : Action = null
var strike_info : StrikeInfo = null

var groups : Array = []
var child_of_sender : bool = false
var sender_exception : bool = false

#####################
### Configuration ###
#####################

func attack_construct() -> void:
	pass

func attack_prepare() -> void:
	pass
	
var __constructed = false 
func _ready() -> void:
	if not __constructed && self.has_method("construct"):
		self.call("construct")
	if self.has_method("prepare"): self.call("prepare")
	
###############
### Helpers ###
###############
		
func config(o : Object) -> void:
	add_any_exceptions(o)
	if o is Node:
		add_to_parent(o)
		add_to_groups(o)
		if o is Entity:
			move(o)
			
func move(e : Entity) -> void:
	var off = offset
	if flip_h: off.x *= -1
	if flip_v: off.y *= -1
	if not child_of_sender && at_sender && sender.get_ref() != null:
		e.move_to(sender.get_ref().get_position() + off)
		return
	e.move_to(position + off)
	
func add_to_groups(node : Node) -> void:
	for s in groups: node.add_to_group(s)
	
func add_to_parent(node : Node) -> void:
	var par = (sender if child_of_sender else parent)
	if par.get_ref() == null: 
		push_error("Lost parent in Attack.")
	par.get_ref().add_child(node)
	
func add_any_exceptions(o : Object) -> void:
	if not sender_exception: return
	if o != null && o.has_method("add_exception"):
		o.call("add_exception", sender)
		
#########################
### Callback Defaults ###
#########################

func callback() -> void: pass
func cancelled() -> void: pass
func finished() -> void: pass
	
##############
### Firing ###
##############

func fire() -> Action:
	return Action.new()
	
func get_strike_info() -> StrikeInfo:
	if strike_info != null: 
		var copy = dict2inst(inst2dict(strike_info))
		if copy is StrikeInfo: return copy
		return null
	return get_default_strike()
	
func get_action() -> Action:
	if action != null: 
		var copy = dict2inst(inst2dict(action))
		if copy is Action: return copy
		return null
	return get_default_action()
	
func get_default_strike() -> StrikeInfo:
	var strike = StrikeInfo.new()
	strike.source = self
	return strike
	
func get_default_action() -> Action:
	return Action.new()
	
#########################
### Getters / Setters ###
#########################

func set_ownership(send : WeakRef, par : WeakRef) -> void:
	self.sender = send
	self.parent = par

func set_spawn_at_sender(s : bool):
	at_sender = s

func set_position(pos : Vector2) -> void:
	self.position = pos
	
func set_offset(off : Vector2) -> void:
	self.offset = off

func set_flip_h(f : bool) -> void:
	self.flip_h = f
	
func set_flip_v(f : bool) -> void:
	self.flip_v = f
	
func set_action(a : Action) -> void:
	self.action = a
	
func set_strike_info(si : StrikeInfo) -> void:
	self.strike_info = si

func set_groups(g : Array) -> void:
	self.groups = g

func set_child_of_sender(c : bool) -> void:
	self.child_of_sender = c
	
func set_sender_exception(se : bool) -> void:
	self.sender_exception = se
	
func get_card_texture() -> Texture:
	return CardInfo.get_random_card_back()
