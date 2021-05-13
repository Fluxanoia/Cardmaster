class_name Projectile
extends Entity

var shape      : Shape2D = null
var tween      : Tween = null
var visibility : VisibilityNotifier2D = null

var health : float = 0
var damageable : bool = false
var strikes : int = -1

var auto_free : bool = true

#####################
### Configuration ###
#####################

func projectile_construct(cs : Shape2D, cso : Vector2, 
		ds : Shape2D, dso : Vector2) -> void:
	self.entity_construct(cs, cso, ds, dso)
	# Create children
	tween = Tween.new()
	visibility = VisibilityNotifier2D.new()
	# Clear the collision bits
	self.set_collision_mask(0)
	self.set_collision_layer(0)
	# Add the children
	self.add_child(tween)
	self.add_child(visibility)
	
func projectile_prepare() -> void:
	self.entity_prepare()
	Globals.handle_error(
		visibility.connect("screen_exited", self, "__screen_exited"))

##################
### Collisions ###
##################
	
func handle_intersections() -> void:
	if not damageable: return
	var all = gather_intersections()
	if all.size() == 0: return
	var intersections = []
	for i in all:
		if i.has_method("is_passive"):
			if i.is_passive(): continue
		else: continue
		intersections.push_back(i)
	var striker
	while intersections.size() > 0:
		striker = randi() % intersections.size()
		var s = intersections[striker]
		if !s.has_method("get_strike_info") || !s.has_method("get_position"):
			intersections.remove(striker)
			continue
		self.strike(s.get_strike_info())
		intersections.remove(striker)

func strike(info : StrikeInfo) -> void:
	if info == null: return
	if info.source != null && info.source.get_ref() != null:
		var src = info.source.get_ref()
		if src.has_method("get_type"):
			if src.get_type() == EntityInfo.EntityType.PROJECTILE:
				health -= info.damage
				if health <= 0: 
					self.dead()
					return
	self.knockback(info)
	if info.source != null && info.source.get_ref() != null:
		var src = info.source.get_ref()
		if src.has_method("has_struck"): src.has_struck()
	self.emit_signal("struck", info)

func handle_strikes() -> void:
	if strikes > 0: strikes -= 1
	if strikes == 0: dead()

func has_struck() -> void:
	self.handle_strikes()

func fire(_angle : float) -> void:
	pass
	
func knockback(info : StrikeInfo):
	if info == null: return
	var dir = Globals.RIGHT
	if info.knockback_angle_override:
		dir = Globals.RIGHT.rotated(info.knockback_angle)
	elif info.source != null && info.source.get_ref() != null:
		var src = info.source.get_ref()
		if src.has_method("get_position"):
			dir = self.position - src.get_position()
	velocity = dir.normalized() * info.knockback * knockback_resist
	
##############
### Memory ###
##############

func __screen_exited() -> void:
	if auto_free: queue_free()

#######################
### Getters/Setters ###
#######################

func set_strikes(s : int) -> void:
	strikes = s

func get_type() -> int:
	return EntityInfo.EntityType.PROJECTILE
