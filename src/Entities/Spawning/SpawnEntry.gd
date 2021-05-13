class_name SpawnEntry
extends Resource

var spawn_type   : int = EntityInfo.ActorType.PLAYER
var spawn_module : int = EntityInfo.ControlType.NONE
var spawn_weight : int = 1

var calls : Array = []

func construct(type : int, module : int, weight : int) -> void:
	self.spawn_type = type
	self.spawn_module = module
	self.spawn_weight = weight

func spawn() -> Entity:
	var e = EntityInfo.get_actor(spawn_type)
	if e != null:
		e.module_code = spawn_module
		var func_name : String
		var func_args : Array
		for c in calls:
			if not c[0] is String: 
				print("Non-string function name in SpawnEntry.spawn().")
				continue
			func_name = c[0]
			func_args = Array.slice(1, c.size() - 1)
			if not e.has_method(func_name): 
				print("Entity of type " + str(spawn_type)
					+ " does not have a method: " + func_name + ".")
				continue
			e.callv(func_name, func_args)
	return e

func set_calls(list : Array): calls = list

func get_spawn_type() -> int: return spawn_type

func get_spawn_weight() -> int: return spawn_weight
