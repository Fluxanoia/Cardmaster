class_name SpawnArea
extends Resource

var mob_list : Array = []
var spawn_rate : int = 600

var shape : Rect2 = Rect2(0, 0, 0, 0)

func construct(rect : Rect2, rate : int) -> void:
	self.shape = rect
	self.spawn_rate = rate
	
func get_random_spawn() -> SpawnEntry:
	if (randi() % spawn_rate) != 0: return null
	var full_weight : int = 0
	for s in mob_list:
		if s is SpawnEntry: full_weight += s.get_spawn_weight()
	var cumu_weight : int = 0
	var rand : int = randi() % full_weight
	for s in mob_list:
		if s is SpawnEntry: 
			cumu_weight += s.get_spawn_weight()
			if cumu_weight > rand:
				return s
	return null
	
func has_point(point : Vector2) -> bool:
	return shape.has_point(point)
	
func add_spawn_entry(entry : SpawnEntry) -> void:
	mob_list.push_back(entry)
	
func remove_spawn_entry(entry : SpawnEntry) -> void:
	Globals.array_remove(mob_list, entry, true)

func get_spawn_entries() -> Array:
	return mob_list
