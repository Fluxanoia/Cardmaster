class_name Demon
extends Actor

var attack : BasicAOE

var damaged_sound : AudioStream = preload("res://audio/sfx/damage/damage17.ogg")

func construct() -> void:
	__constructed = true
	# Frames
	sprite = Sprite.new()
	sprite_frames = EntityInfo.get_actor_frames(self.get_id())
	self.set_animation("attack", false, -1)
	self.add_child(sprite)
	# Superclass
	var s = EntityInfo.get_actor_shape(
		EntityInfo.ActorType.DEMON)
	var o = EntityInfo.get_actor_shape_offset(
		EntityInfo.ActorType.DEMON)
	physics_type = Entity.PhysicsType.GRAVITY
	health_dim.position.y = 60
	self.actor_construct(s, o, s, o, true)
	gravity_params.JUMP_MAX_TIME = 0.7
	gravity_params.ACCELERATION = 7
	gravity_params.MAX_SPEED = 100
	# Configure strike info
	passive = false
	strike_info.damage = 5
	strike_info.knockback = 500
	strike_info.stops = true
	strike_info.oneshot = false
	# Configure the attack
	attack = BasicAOE.new()
	attack.set_ownership(weakref(self), weakref(self.get_parent()))
	attack.set_position(Vector2(0, 30) * entity_scale)
	attack.set_offset(Vector2(-70, 0) * entity_scale)
	attack.set_groups([EntityInfo.ENEMY_PROJ_GROUP])
	attack.set_child_of_sender(true)
	attack.set_sender_exception(true)
	var attack_shape = RectangleShape2D.new()
	attack_shape.set_extents(Vector2(40, 20) * entity_scale)
	attack.construct(attack_shape, 60, 40)
	
func prepare() -> void:
	# Prepare superclass
	self.actor_prepare()
	# Signals
	Globals.handle_error(self.connect("struck", self, "struck"))
	# Sound
	$DamageStream.set_stream(damaged_sound)
	# Animation
	$Animator.play("idle")
	
func _physics_process(delta : float) -> void:
	self.process_physics(delta)
	if self.process_action(attack): self.generate_new_animation()
	if hp == max_hp:
		health_bar.set_visible(false)
	elif !health_bar.is_visible():
		health_bar.set_visible(true)
	self.handle_animation()
	
func struck(info : StrikeInfo):
	if info.damage > 0: 
		Globals.screen_shake(10, 0.2)
		$DamageStream.play()
	
#################
### Animation ###
#################

func handle_animation():
	# Handle temporary animation and flip
	var flip_h = sprite.is_flipped_h()
	var temp_anim = self.is_using_temp_animation($Animator)
	if temp_anim && self.has_direction_locked():
		var dir = self.get_locked_direction()
		if dir != null: flip_h = dir > 0
	elif velocity.x != 0: flip_h = velocity.x > 0
	sprite.set_flip_h(flip_h)
	attack.set_flip_h(flip_h)
	if temp_anim: return
	if self.is_using_temp_animation($Animator): return
	# Next animation
	var next_anim = "idle"
	if next_anim != $Animator.get_current_animation():
		if $Animator.has_animation(next_anim):
			$Animator.play(next_anim)
		else:
			push_error("Unknown animation " + next_anim + " in Demon.")
	
func generate_new_animation() -> void:
	var anim : Animation
	if $Animator.has_animation(ANIM_TEMP):
		anim = $Animator.get_animation(ANIM_TEMP)
		anim.clear()
	else: anim = Animation.new()
	var len_in_secs = action.length / float(Globals.get_physics_fps())
	anim.set_length(stepify(len_in_secs, ANIM_STEP) + ANIM_STEP)
	anim.set_step(ANIM_STEP)
	var track = anim.add_track(Animation.TYPE_METHOD)
	anim.track_set_path(track, ".")
	# Set the starting frame
	anim.track_insert_key(track, 0, {
		"method" : "set_animation", "args" : ["attack", false, -1]
	})
	# Set the intermediate frames
	var sprite_count = sprite_frames.get_frame_count("attack")
	var time_step = stepify(len_in_secs / sprite_count, ANIM_STEP)
	for i in range(1, sprite_count):
		anim.track_insert_key(track, i * time_step, {
			"method" : "progress_animation", "args" : []
		})
	if not $Animator.has_animation(ANIM_TEMP):
		$Animator.add_animation(ANIM_TEMP, anim)
	use_temp_animation = true	

#########################
### Getters / Setters ###
#########################
	
func get_id() -> int:
	return EntityInfo.ActorType.DEMON
