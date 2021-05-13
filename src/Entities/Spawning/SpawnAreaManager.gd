class_name SpawnAreaManager
extends Node2D

const DRAW_SPAWNS : bool = false
var spawn_rects : Array = []

const SPAWN_RANGE       : int = 500
const CAST_DIST         : int = 100
const SPAWN_ATTEMPTS    : int = 5
const CLUMPING_RADIUS   : int = 200
const DESPAWN_DIST      : int = 6400
const DESPAWN_WAVE_TIME : float = 4.0

export (int) var spawn_cap : int = 10

var exceptions : Array = []
var global_area : SpawnArea = null
var spawn_areas : Array = []

var raycast : RayCast2D
var despawn_timer : Timer

var __constructed : bool = false
func construct() -> void:
	__constructed = true
	# Raycast
	raycast = RayCast2D.new()
	raycast.set_enabled(true)
	raycast.set_cast_to(Vector2(0, CAST_DIST))
	raycast.set_collide_with_areas(false)
	raycast.set_collide_with_bodies(true)
	raycast.set_collision_mask(CollisionInfo.MAIN_COLLISION_BIT + 1)
	self.add_child(raycast)	
	# Timer
	despawn_timer = Timer.new()
	despawn_timer.set_wait_time(DESPAWN_WAVE_TIME)
	
func prepare() -> void:
	Globals.handle_error(
		despawn_timer.connect("timeout", self, "despawn"))
	self.add_child(despawn_timer)
	despawn_timer.start()

func _ready() -> void:
	if not __constructed: construct()
	self.prepare()

func _physics_process(_delta : float) -> void:
	# Check we are within the spawn cap
	var enemies = get_tree().get_nodes_in_group(EntityInfo.ENEMY_GROUP)
	if enemies.size() >= spawn_cap: return
	# Check whether there is a player to spawn around
	var players = get_tree().get_nodes_in_group(EntityInfo.PLAYER_GROUP)
	if players.size() == 0: 
		return
	# Check we aren't in an exception area
	var player_pos = players[randi() % players.size()].get_global_position()
	for e in exceptions: if e.has_point(player_pos): return
	# Get the spawn regions the chosen player is in
	var areas = []
	if global_area != null: areas.push_back(global_area)
	for a in spawn_areas: if a.has_point(player_pos): areas.push_back(a)
	if areas.size() == 0: 
		return
	# Get the spawning entity from a spawn area
	var spawn = areas[randi() % areas.size()].get_random_spawn()
	if spawn == null: 
		return
	var spawn_shape = EntityInfo.get_actor_shape(spawn.get_spawn_type())
	# We now attempt to place the entity
	var tries = 0
	var viewport = get_viewport_rect()
	viewport.position = player_pos - (viewport.size / 2)
	while tries < SPAWN_ATTEMPTS:
		# Get a randome point in the spawn rectangle
		var horz_dist = randi() % SPAWN_RANGE
		var vert_dist = randi() % SPAWN_RANGE
		var spawn_pos = viewport.position
		if (randi() % 2) == 0:
			spawn_pos.x -= horz_dist
		else: spawn_pos.x += viewport.size.x + horz_dist
		if (randi() % 2) == 0:
			spawn_pos.y -= vert_dist
		else: spawn_pos.y += viewport.size.y + vert_dist
		# Check it's not in a exception area
		var exception = false
		for e in exceptions: 
			if e.has_point(spawn_pos): 
				tries += 1
				exception = true
				break
		if exception: continue
		# Check clumping
		var clump = dist_to_closest_enemy(spawn_pos)
		if clump >= 0 && clump <= CLUMPING_RADIUS:
			tries += 1
			continue
		# Prepare the raycast
		raycast.set_position(spawn_pos)
		raycast.force_raycast_update()
		if !raycast.is_colliding():
			tries += 1
			continue
		# Prepare the physics query
		if CollisionInfo.query_world_shape_intersect(get_world_2d(), 
				spawn_shape, spawn_pos):
			tries += 1
			continue
		if DRAW_SPAWNS:
			spawn_rects.push_back(Rect2(
				spawn_pos - Vector2(10, 10),
				Vector2(20, 20)))
			self.update()
		var entity = spawn.spawn()
		entity.set_position(spawn_pos)
		entity.add_to_group(EntityInfo.ENEMY_GROUP)
		self.get_parent().add_child(entity)
		return

func _draw() -> void:
	if DRAW_SPAWNS: for r in spawn_rects:
		draw_rect(r, Color.blue)

func despawn() -> void:
	for e in get_tree().get_nodes_in_group(EntityInfo.ENEMY_GROUP):
		if dist_to_closest_player(e.get_position()) >= DESPAWN_DIST: 
			e.queue_free()

func dist_to_closest_player(pos : Vector2) -> float:
	var dist     : float = -1
	var new_dist : float = 0.0
	for p in get_tree().get_nodes_in_group(EntityInfo.PLAYER_GROUP):
		if not (p is Node2D): continue
		new_dist = p.get_position().distance_to(pos)
		if dist < 0 || new_dist < dist: dist = new_dist
	return dist
	
func dist_to_closest_enemy(pos : Vector2) -> float:
	var dist     : float = -1
	var new_dist : float = 0.0
	for p in get_tree().get_nodes_in_group(EntityInfo.ENEMY_GROUP):
		if not (p is Node2D): continue
		new_dist = p.get_position().distance_to(pos)
		if dist < 0 || new_dist < dist: dist = new_dist
	return dist

func add_spawn_area(area : SpawnArea):
	spawn_areas.push_back(area)
	
func remove_spawn_area(area : SpawnArea):
	Globals.remove_instances_in(spawn_areas, area, true)

func add_exception(e : Rect2):
	exceptions.push_back(e)
	
func remove_exception(e : Rect2):
	Globals.remove_instances_in(exceptions, e, true)
	
func get_global_spawns() -> SpawnArea:
	return global_area
	
func set_global_spawns(area : SpawnArea) -> void:
	global_area = area
	
