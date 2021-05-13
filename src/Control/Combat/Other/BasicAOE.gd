class_name BasicAOE
extends Attack

var shape : Shape2D
var delay : int
var length : int

func construct(s : Shape2D, wait : int, time : int) -> void:
	__constructed = true
	self.shape = s
	self.delay = wait
	self.length = time
	
func fire() -> Action:
	return get_action()

func callback() -> void:
	var aoe = AOE.new()
	var strike = get_strike_info()
	strike.source = weakref(aoe)
	aoe.construct(shape, length, strike)
	self.config(aoe)

func get_default_strike() -> StrikeInfo:
	var strike = StrikeInfo.new()
	strike.oneshot = true
	strike.damage = 10
	strike.knockback = 500
	strike.stops = true
	return strike
	
func get_default_action() -> Action:
	var a = Action.new()
	a.length = 100
	a.callback = weakref(self)
	a.callback_frames = [delay]
	a.attack_frames = a.callback_frames
	a.lock_direction = true
	a.stoppable = false
	a.allowlist = true
	a.restrict_length = a.length
	return a
