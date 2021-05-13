class_name HighCard
extends Attack

var angle : float = 0

func construct() -> void:
	__constructed = true

func fire() -> Action:
	if sender.get_ref() == null: return null
	var bft = sender.get_ref().get_module().get_angle_from(sender.get_ref())
	if !bft.b: return null
	angle = bft.f
	return get_action()

func callback() -> void:
	var p = BasicCard.new()
	var strike = get_strike_info()
	strike.source = weakref(p)
	p.construct(900, strike)
	self.config(p)
	if sender.get_ref() != null:
		var bft = sender.get_ref().get_module().get_angle_from(sender.get_ref())
		if bft.b: angle = bft.f
	p.fire(angle)

func get_default_strike() -> StrikeInfo:
	var strike = StrikeInfo.new()
	strike.damage = 10
	strike.knockback = 150
	return strike
	
func get_default_action() -> Action:
	var a = Action.new()
	a.length = 80
	a.callback = weakref(self)
	a.callback_frames = [20, 40, 60]
	a.attack_frames = a.callback_frames
	a.allowlist = true
	a.restrict_length = 60
	a.lock_direction = true
	if angle > -PI / 2 and angle < PI / 2:
		a.locked_direction = Globals.Side.RIGHT
	else: a.locked_direction = Globals.Side.LEFT
	return a
	
func get_card_texture():
	return load("res://images/cards/attacks/highcard.png")
