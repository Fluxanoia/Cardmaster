extends Node

# The different groups used by entities
const PLAYER_GROUP : String = "world_players"
const ENEMY_GROUP : String = "world_enemies"
const PLAYER_PROJ_GROUP : String = "world_player_proj"
const ENEMY_PROJ_GROUP : String = "world_enemy_proj"

# The pairings of groups
const ENEMY_GROUPS = [ENEMY_GROUP, ENEMY_PROJ_GROUP]
const PLAYER_GROUPS = [PLAYER_GROUP, PLAYER_PROJ_GROUP]

# The types of control module
enum ControlType { NONE, PLAYER, ZOMBIE }

# The different entity types
enum EntityType { PROJECTILE, ACTOR }

# The types of actors and corresponding packed scenes
enum ActorType { PLAYER, DEMON }
var ACTOR_PLAYER : PackedScene = preload("res://src/Entities/Player/Player.tscn")
var ACTOR_DEMON : PackedScene = preload("res://src/Entities/Demon/Demon.tscn")
# The sprite frames
var ACTOR_PLAYER_SF : SpriteFrames = preload("res://images/sprites/cardmaster/frames.tres")
var ACTOR_DEMON_SF : SpriteFrames = preload("res://images/sprites/demon/frames.tres")

################
### Entities ###
################ 

# Returns true if the two strings are groups that are sisters of
# each other
func is_sister_of(a : String, b : String) -> bool:
	var sisters = [ENEMY_GROUPS, PLAYER_GROUPS]
	for s in sisters: if a in s && b in s: return true
	return false

# Returns whether two objects share a sister group between them
func share_sister_groups(a : Object, b : Object) -> bool:
	var ag = a.get_groups()
	var bg = b.get_groups()
	for g1 in ag: for g2 in bg:
		if is_sister_of(g1, g2): return true
	return false

# Returns the actor corresponding to the given ActorType
func get_actor(type : int) -> Actor:
	var a = null
	if (type == ActorType.PLAYER): a = ACTOR_PLAYER.instance()
	if (type == ActorType.DEMON): a = ACTOR_DEMON.instance()
	# Returning and type checking
	if a == null: 
		push_error("Unknown actor type.")
		return null
	if a is Actor: return a
	push_error("Instanced actor was not an actor.")
	return null

# Returns the sprite frames corresponding to a given ActorType
func get_actor_frames(type : int) -> SpriteFrames:
	var sf = null
	if (type == ActorType.PLAYER): sf = ACTOR_PLAYER_SF
	if (type == ActorType.DEMON): sf = ACTOR_DEMON_SF
	# Returning and type checking
	if sf == null: 
		push_error("Unknown actor type.")
		return null
	return sf

# Returns the shape corresponding to a given ActorType
func get_actor_shape(type : int) -> Shape2D:
	var shape = RectangleShape2D.new()
	if (type == ActorType.PLAYER): shape.set_extents(Vector2(10.8, 17.5))
	if (type == ActorType.DEMON): shape.set_extents(Vector2(25.2, 35.3))
	return shape
	
# Returns the shape offset corresponding to a given ActorType
func get_actor_shape_offset(type : int) -> Shape2D:
	var offset = Vector2()
	if (type == ActorType.PLAYER): offset = Vector2(0, 0)
	if (type == ActorType.DEMON): offset = Vector2(0, 19.8)
	return offset
		
###############
### Control ###
###############

# Returns the control module corresponding to the given ControlType
func get_control_module(module : int) -> ControlModule:
	if (module == ControlType.NONE):
		return ControlModule.new()
	if (module == ControlType.PLAYER):
		return UserModule.new()
	if (module == ControlType.ZOMBIE):
		return ZombieModule.new()
	push_error("Unknown control module type.")
	return ControlModule.new()
	
