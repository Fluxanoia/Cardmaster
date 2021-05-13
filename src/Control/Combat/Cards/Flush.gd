class_name Flush
extends Attack

var angle : float = 0
var angle_variation : float 

func construct(angle_var : float = 15.0) -> void:
	__constructed = true
	self.angle_variation = angle_var

func fire() -> Action:
	if sender.get_ref() == null: return null
	var bft = sender.get_ref().get_module().get_angle_from(sender.get_ref())
	if !bft.b: return null
	angle = bft.f
	return get_action()

func callback() -> void:
	if sender.get_ref() != null:
		var bft = sender.get_ref().get_module().get_angle_from(sender.get_ref())
		if bft.b: angle = bft.f
	var angle_range = deg2rad(angle_variation)
	var min_angle = -angle_range / 2
	for _i in range(5 + randi() % 6):
		var p = BasicCard.new()
		var strike = get_strike_info()
		strike.source = weakref(p)
		p.construct(500, strike)
		p.set_strikes(1)
		self.config(p)
		var angle_wobble = min_angle + randf() * angle_range
		p.fire(angle + angle_wobble)

func get_default_strike() -> StrikeInfo:
	var strike = StrikeInfo.new()
	strike.damage = 5
	strike.knockback = 30
	return strike
	
func get_default_action() -> Action:
	var a = Action.new()
	a.length = 60
	a.callback = weakref(self)
	a.callback_frames = [40]
	a.attack_frames = a.callback_frames
	a.allowlist = true
	a.restrict_length = 40
	a.lock_direction = true
	if angle > -PI / 2 and angle < PI / 2:
		a.locked_direction = Globals.Side.RIGHT
	else: a.locked_direction = Globals.Side.LEFT
	return a
	
func get_card_texture():
	return load("res://images/cards/attacks/flush.png")
