class_name BasicCard
extends Projectile

var tween_duration : float = 0.1
var scale_min : Vector2 = Vector2(0.05, 0.05)
var scale_max : Vector2 = Vector2(0.1, 0.1)

var audio : AudioStreamPlayer

func construct(speed : float = 0, 
		si : StrikeInfo = null) -> void:
	__constructed = true
	# Create the audio player
	audio = AudioStreamPlayer.new()
	# Create the sprite
	sprite = Sprite.new()
	sprite.set_texture(CardInfo.get_random_card_front())
	# Create the shape
	shape = RectangleShape2D.new()
	shape.set_extents(scale_max * sprite.get_rect().size / 2)
	# Superclass
	physics_type = Entity.PhysicsType.ZERO_GRAVITY
	self.projectile_construct(shape, Vector2(), shape, Vector2())
	# Add the children	
	self.add_child(audio)
	self.add_child(sprite)
	# Configure collision
	strike_info = si
	passive = (strike_info == null)
	zerog_params.MAX_SPEED = speed
	self.set_collision_mask_bit(CollisionInfo.MAIN_COLLISION_BIT, true)
	
func prepare() -> void:
	self.projectile_prepare()
	Globals.error_on_false(tween.interpolate_property(sprite, "modulate:a", 
		0, 1, tween_duration, Tween.TRANS_QUAD, Tween.EASE_IN))
	Globals.error_on_false(tween.interpolate_property(sprite, "scale", 
		scale_min, scale_max, tween_duration, Tween.TRANS_QUAD, Tween.EASE_IN))
	sprite.set_scale(scale_min)
	Globals.error_on_false(tween.start())
	
func fire(angle : float) -> void:
	velocity = zerog_params.MAX_SPEED * Globals.RIGHT
	velocity = velocity.rotated(angle)
	audio.set_stream(CardInfo.get_random_card_throw())
	audio.play()
	
func has_struck() -> void:
	self.handle_strikes()
	audio.set_stream(CardInfo.get_random_card_hit())
	audio.play()
	
func _physics_process(delta : float) -> void:
	self.process_physics(delta)
	var rot = velocity.angle() + PI / 2
	self.set_rotation(rot)
	if self.get_slide_count() > 0: 
		audio.set_stream(CardInfo.get_random_card_hit())
		audio.play()
		queue_free()
