class_name CardPickup
extends Attack

func construct() -> void:
	__constructed = true

func fire() -> Action:
	return get_action()

func callback() -> void:
	for _i in range(6):
		var p = BasicCard.new()
		var strike = get_strike_info()
		strike.source = weakref(p)
		p.construct(700, strike)
		p.switch_physics(Entity.PhysicsType.GRAVITY)
		p.set_strikes(1)
		self.config(p)
		p.fire(2 * PI * randf())

func get_default_strike() -> StrikeInfo:
	var strike = StrikeInfo.new()
	strike.damage = 2
	strike.knockback = 1200
	return strike
	
func get_default_action() -> Action:
	var a = Action.new()
	a.length = 100
	a.callback = weakref(self)
	a.callback_frames = [60, 65, 70, 75]
	a.attack_frames = a.callback_frames
	a.stoppable = false
	a.allowlist = true
	a.restrict_length = 100
	return a
	
func get_card_texture():
	return load("res://images/cards/attacks/cardpickup.png")
