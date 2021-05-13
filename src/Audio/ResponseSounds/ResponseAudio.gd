class_name ResponseAudio
extends Resource

var folder : String = ""
var files  : Array = []
var tiles  : Array = []

var sounds : Array = []

func load_all(prefix : String, suffix : String) -> void:
	for p in files:
		var stream = load(prefix + folder + "/" + p + suffix)
		if stream is AudioStream: sounds.append(stream)

func get_random_sound() -> AudioStream:
	if sounds.size() == 0: 
		push_error("No sounds in ResponseAudio: " + folder + ".")
		return null
	return sounds[randi() % sounds.size()]

func get_folder() -> String:
	return folder
	
func get_files() -> Array:
	return files
	
func get_tiles() -> Array:
	return tiles
