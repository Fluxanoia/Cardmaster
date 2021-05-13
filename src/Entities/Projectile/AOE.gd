class_name AOE
extends Projectile

var time_left : int

func construct(s : Shape2D, length : int, si : StrikeInfo = null) -> void:
	__constructed = true
	# Set variables
	self.shape = s
	self.time_left = length
	# Superclass
	physics_type = Entity.PhysicsType.ZERO_GRAVITY
	projectile_construct(shape, Vector2(), shape, Vector2())
	# Configure collision
	strike_info = si
	passive = (strike_info == null)
	self.set_collision_mask_bit(CollisionInfo.MAIN_COLLISION_BIT, true)
	
func prepare() -> void:
	pass
	
func _physics_process(_delta : float) -> void:
	time_left -= 1
	if time_left < 0: queue_free()
	
