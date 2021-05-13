extends Node

const RESPONSE_PATH   = "res://audio/sfx/response/"
const RESPONSE_ENDING = ".ogg"

enum ResponseType { GRASS, STONE, WOOD }
var grass = GrassAudio.new()
var stone = StoneAudio.new()
var wood = WoodAudio.new()
var metal = MetalAudio.new()
var audios = [grass, stone, wood, metal]

func _ready():
	for a in audios: a.load_all(RESPONSE_PATH, RESPONSE_ENDING)

func get_response_from_tile(name : String) -> AudioStream:
	var i = 0
	while i < audios.size():
		var a = audios[i]
		if not a is ResponseAudio:
			push_error("Object not of type ResponseAudio in ResponseSound.")
			return null
		elif name in a.get_tiles():
			return get_response_from_type(i)
		i += 1
	push_error("Tile not associated to audio response: " + name + ".")
	return null
	
func get_response_from_type(type : int) -> AudioStream:
	if type < 0 || type >= audios.size():
		push_error("Unknown audio response type: " + str(type) + ".")
		return null
	return audios[type].get_random_sound()
