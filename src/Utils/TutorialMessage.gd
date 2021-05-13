class_name TutorialMessage
extends Label

const CONTROL_DIST = 60
const Y_DIST = 40

export (Texture) var img_1 : Texture = null
export (Texture) var img_2 : Texture = null
export (Texture) var img_3 : Texture = null
export (Texture) var img_4 : Texture = null

var sprites : Array = []

func construct() -> void:
	var material = Globals.get_outline_shader(0.5, Color(0, 0, 0, 0.5))
	for i in [img_1, img_2, img_3, img_4]:
		if i == null: continue
		var s = Sprite.new()
		s.set_texture(i)
		s.set_material(material)
		sprites.push_back(s)
	if sprites.size() == 0: return
	var ctrl_width = CONTROL_DIST * (sprites.size() - 1)
	var ctrl_x = rect_size.x / 2 - ctrl_width / 2
	var ctrl_y = rect_size.y + Y_DIST
	for i in range(sprites.size()):
		sprites[i].set_position(Vector2(
			ctrl_x + i * CONTROL_DIST, ctrl_y))
		self.add_child(sprites[i])
	
var __constructed = false 
func _ready() -> void:
	if not __constructed && self.has_method("construct"):
		self.call("construct")
	if self.has_method("prepare"): self.call("prepare")
