class_name Village
extends Node2D

var spawn_exceptions : Array = [
	Rect2(-816, -384, 656, 384),
	Rect2(2640, 0, 656, 304),
	Rect2(-160, -128, 320, 864)]

func _ready() -> void:
	var spawns : SpawnArea = SpawnArea.new()
	var demon_entry : SpawnEntry = SpawnEntry.new()
	spawns.construct(Rect2(), 2)
	demon_entry.construct(EntityInfo.ActorType.DEMON,
		EntityInfo.ControlType.ZOMBIE, 1)
	spawns.add_spawn_entry(demon_entry)
	$SpawnAreaManager.set_global_spawns(spawns)
	for r in spawn_exceptions:
		$SpawnAreaManager.add_exception(r)
