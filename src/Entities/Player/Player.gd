class_name Player
extends Actor

const PUNCH_FRAMES = [3, 7, 11]
const JUMP_WALL_MODIFIER : float = 1.5
const WALL_SLIDE_MODIFIER : float = 0.75

const PLAYER_HP_UNDER = "res://images/ui/player_hp_under.png"
const PLAYER_HP_PROG = "res://images/ui/player_hp_progress.png"

var last_jumped_wall = null
var deck : Deck = null

var floor_raycast : RayCast2D
var health_bar_canvas : CanvasLayer

var dead_sound    : AudioStream = preload("res://audio/sfx/damage/damage28.ogg")
var damaged_sound : AudioStream = preload("res://audio/sfx/damage/damage27.ogg")
var attack_sound  : AudioStream = preload("res://audio/sfx/card/cardTakeOutPackage1.ogg")

func construct() -> void:
	__constructed = true
	# Frames
	sprite = Sprite.new()
	sprite_frames = EntityInfo.get_actor_frames(self.get_id())
	self.set_animation("idle", false, -1)
	self.add_child(sprite)
	# Superclass
	entity_scale = Vector2(1.5, 1.5)
	var s = EntityInfo.get_actor_shape(
		EntityInfo.ActorType.PLAYER)
	var o = EntityInfo.get_actor_shape_offset(
		EntityInfo.ActorType.PLAYER)
	physics_type = Entity.PhysicsType.GRAVITY
	self.actor_construct(s, o, s, o, true)
	# I-frames
	self.i_frames_length = 30
	# Raycast
	floor_raycast = RayCast2D.new()
	floor_raycast.set_enabled(true)	
	floor_raycast.set_cast_to(Vector2(0, sprite.get_rect().size.y))
	floor_raycast.set_position(Vector2(0, 0))
	floor_raycast.set_collision_mask(0)
	floor_raycast.set_collision_mask_bit(CollisionInfo.MAIN_COLLISION_BIT, true)
	floor_raycast.set_collision_mask_bit(CollisionInfo.DROPTHRU_COLLISION_BIT, true)
	self.add_child(floor_raycast)
	# Sound
	$AttackStream.set_stream(attack_sound)
	# Deck
	deck = preload("res://src/Control/Combat/Cards/Deck.gd").new()
	deck.construct(self, self.get_parent())
	self.get_parent().add_child(deck)

func prepare() -> void:
	# Prepare superclass
	self.actor_prepare()
	# Signals
	Globals.handle_error(
		self.connect("finalise_physics", self, "finalise_physics"))
	Globals.handle_error(self.connect("struck", self, "struck"))
	# Sound
	$DamageStream.set_stream(damaged_sound)
	# Animation
	$Animator.play("fall")
	# Deck
	self.add_attacks()
	
func add_attacks() -> void:
	var attack : Attack
	# HighCard
	attack = HighCard.new()
	attack.construct()
	attack.set_spawn_at_sender(true)
	attack.set_groups([EntityInfo.PLAYER_PROJ_GROUP])
	attack.set_sender_exception(true)
	deck.add_card(attack)
	# Flush
	attack = Flush.new()
	attack.construct(25)
	attack.set_spawn_at_sender(true)
	attack.set_groups([EntityInfo.PLAYER_PROJ_GROUP])
	attack.set_sender_exception(true)
	deck.add_card(attack)
	# 52 Card Pickup
	attack = CardPickup.new()
	attack.construct()
	attack.set_spawn_at_sender(true)
	attack.set_groups([EntityInfo.PLAYER_PROJ_GROUP])
	attack.set_sender_exception(true)
	deck.add_card(attack)
	
func _configure_health_bar(auto_image : bool = true) -> void:
	if health_bar != null: return
	health_bar = TextureProgress.new()
	health_bar.rect_position = Vector2(20, 20)
	health_bar.rect_scale = Vector2(5, 5)
	if auto_image:
		health_under_texture = load(PLAYER_HP_UNDER)
		health_progress_texture = load(PLAYER_HP_PROG)
	health_bar.set_under_texture(health_under_texture)
	health_bar.set_progress_texture(health_progress_texture)
	health_bar.set_over_texture(health_over_texture)
	health_bar.set_max(max_hp)
	health_bar.set_value(hp)
	health_bar_canvas = CanvasLayer.new()
	health_bar_canvas.add_child(health_bar)
	self.get_parent().add_child(health_bar_canvas)
	
###############
### Physics ###
###############

func _physics_process(delta : float) -> void:
	# Physics and input gathering
	self.process_physics(delta, not dying)
	if dying: return
	# Deck cycling
	if Input.is_action_just_pressed("ctrl_cycle_left"):
		deck.cycle_selection(Globals.Side.LEFT)
	if Input.is_action_just_pressed("ctrl_cycle_right"):
		deck.cycle_selection(Globals.Side.RIGHT)
	# Firing
	if self.process_action(deck): 
		$AttackStream.play()
		Globals.screen_shake(10, 0.2)
		self.generate_new_animation()
	# Landing step
	if just_landed: audio_footstep()
			
func finalise_physics(_delta : float) -> void:
	# Wall jumping
	if is_on_floor():
		last_jumped_wall = null
	if is_on_wall():
		var wall_jump = jump_timer.is_stopped()
		wall_jump = wall_jump && module.has_input(InputInfo.Inputs.JUMP, true)
		if wall_jump:
			var wall = get_which_wall_collided()
			if last_jumped_wall != wall:
				velocity.x = gravity_params.MAX_SPEED
				velocity.x *= JUMP_WALL_MODIFIER * wall * -1
				velocity.y = gravity_params.JUMP_STRENGTH 
				velocity.y *= JUMP_WALL_MODIFIER
				last_jumped_wall = wall
		else: velocity.y *= WALL_SLIDE_MODIFIER

#################
### Collision ###
#################

func struck(info : StrikeInfo):
	if info.damage > 0: 
		Globals.screen_shake(50, 0.4)
		if not dying: $DamageStream.play()

# Called when this entity dies
func dead() -> void:
	if dying: return
	self.dying = true
	$DamageStream.set_stream(dead_sound)
	$DamageStream.play()
	$Animator.play("die")

#############
### Audio ###
#############

func audio_footstep() -> void:
	floor_raycast.set_collision_mask(self.get_collision_mask())
	if not floor_raycast.is_colliding(): return
	var name : String = ""
	var tm = floor_raycast.get_collider()
	if tm is TileMap:
		var loc = tm.world_to_map(floor_raycast.get_collision_point())
		var cell = tm.get_cell(loc.x, loc.y)
		name = tm.get_tileset().tile_get_name(cell)
	if name.length() == 0: return
	var a = ResponseSound.get_response_from_tile(name)
	if a == null: return
	$FootstepStream.set_stream(a)
	$FootstepStream.play()

#################
### Animation ###
#################
	
func generate_new_animation() -> void:
	var anim : Animation
	if $Animator.has_animation(ANIM_TEMP):
		anim = $Animator.get_animation(ANIM_TEMP)
		anim.clear()
	else: anim = Animation.new()
	var len_in_secs = action.length / float(Globals.get_physics_fps())
	anim.set_length(stepify(len_in_secs, ANIM_STEP) - ANIM_STEP)
	anim.set_step(ANIM_STEP)
	var track = anim.add_track(Animation.TYPE_METHOD)
	anim.track_set_path(track, ".")
	var attacks = action.attack_frames.duplicate(true)
	if attacks.size() == 0:
		anim.track_insert_key(track, 0, {
			"method" : "set_animation", "args" : ["cast_loop", false, 5]
		})
	elif attacks.size() < 4:
		# Set the starting frame
		anim.track_insert_key(track, 0, {
			"method" : "set_animation", "args" : ["punch", false, -1]
		})
		# Make the attacks cumulative
		for i in range(attacks.size() - 1, 0, -1):
			attacks[i] -= attacks[i - 1]
		# Add all the progressions
		var ticks = 0
		var next_sprite = 1
		for p in PUNCH_FRAMES:
			if attacks.size() == 0: break
			var ran = range(next_sprite, p + 1)
			var tick_step = attacks[0] / ran.size()
			for i in ran:
				var time = ticks + tick_step * (i - ran.min() + 1)
				time /= float(Globals.get_physics_fps())
				anim.track_insert_key(track, stepify(time, ANIM_STEP), {
					"method" : "progress_animation", "args" : []
				})
			ticks += attacks[0]
			next_sprite = p + 1
			attacks.remove(0)
		# Set the end frame
		var time = ticks / float(Globals.get_physics_fps())
		anim.track_insert_key(track, stepify(time, ANIM_STEP), {
			"method" : "progress_animation", "args" : []
		})
	else:
		# Set the starting frame
		anim.track_insert_key(track, 0, {
			"method" : "set_animation", "args" : ["cast_start", false, -1]
		})
		# Set the intermediate frames
		var sprite_count = sprite_frames.get_frame_count("cast_start")
		var time_step = attacks[0] / sprite_count
		for i in range(1, sprite_count):
			var time = i * time_step / float(Globals.get_physics_fps())
			anim.track_insert_key(track, stepify(time, ANIM_STEP), {
				"method" : "progress_animation", "args" : []
			})
		# Set the end frames
		var time = sprite_count * time_step 
		time /= float(Globals.get_physics_fps())
		anim.track_insert_key(track, stepify(time, ANIM_STEP), {
			"method" : "progress_animation", "args" : []
		})
	if not $Animator.has_animation(ANIM_TEMP):
		$Animator.add_animation(ANIM_TEMP, anim)
	use_temp_animation = true
	
func handle_animation():
	if dying: return
	# Handle temporary animation and flip
	var flip_h = sprite.is_flipped_h()
	var temp_anim = self.is_using_temp_animation($Animator)
	if temp_anim && self.has_direction_locked():
		var dir = self.get_locked_direction()
		if dir != null: flip_h = dir < 0
	elif velocity.x != 0: flip_h = velocity.x < 0
	sprite.set_flip_h(flip_h)
	if temp_anim: return
	# Ground animation
	var next_anim = "idle"
	if is_on_floor():
		if velocity.x != 0:
			if abs(velocity.x) > 100: 
				next_anim = "run"
			else: next_anim = "walk"
	# Jumping animation
	else:
		if velocity.y < 0:
			next_anim = "jump"
		elif is_on_wall():
			next_anim = "slide_wall"
		else: next_anim = "fall"
	# Config
	if next_anim != $Animator.get_assigned_animation():
		if $Animator.has_animation(next_anim):
			$Animator.play(next_anim)
		else:
			push_error("Unknown animation " + next_anim + " in Player.")
		
#########################
### Getters / Setters ###
#########################
	
func get_id() -> int:
	return EntityInfo.ActorType.PLAYER
