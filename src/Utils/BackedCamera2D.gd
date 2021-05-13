class_name BackedCamera2D
extends Camera2D

# The background sprite
var sprite : Sprite = null
# The background texture
export (Texture) var exported_texture : Texture = null
# The target dimensions of the camera in local size
export (Vector2) var target_dim : Vector2 = Vector2(1280, 720)

# The shake tween
var shake_tween : Tween
export (float) var shake_intensity : float = 0

func construct(tex : Texture = exported_texture) -> void:
	__constructed = true
	shake_tween = Tween.new()
	sprite = Sprite.new()
	sprite.set_texture(tex)
	sprite.set_z_index(-100)
	self.add_child(shake_tween)
	self.add_child(sprite)
	
func prepare() -> void:
	Globals.handle_error(
		get_tree().get_root().connect("size_changed", self, "resize"))
	Globals.handle_error(Globals.connect("screen_shake", self, "shake"))
	self.resize()
	
var __constructed = false 
func _ready() -> void:
	if not __constructed && self.has_method("construct"):
		self.call("construct")
	if self.has_method("prepare"): self.call("prepare")
	
func process_shake():
	if shake_tween.is_active():
		self.set_h_offset(shake_intensity / 100.0 * randf())
		self.set_v_offset(shake_intensity / 100.0 * randf())
	else: 
		self.set_h_offset(0)
		self.set_v_offset(0)
		
func shake(i : float, d : float, t : int, e : int):
	Globals.error_on_false(shake_tween.remove_all())
	Globals.error_on_false(shake_tween.interpolate_property(self,
		"shake_intensity", i, 0, d, t, e))
	Globals.error_on_false(shake_tween.start())
		
# Resize the camera to it's target size in the viewport
func resize() -> void:
	var viewport = get_viewport_rect()
	if viewport.has_no_area(): 
		return
	self.set_zoom(Vector2(target_dim.x / viewport.size.x,
		target_dim.y / viewport.size.y))
	if not (sprite != null && sprite.get_texture() != null): return
	var tex = sprite.get_texture()
	var x_scale = viewport.size.x / tex.get_width()
	var y_scale = viewport.size.y / tex.get_height()
	x_scale *= self.get_zoom().x
	y_scale *= self.get_zoom().y
	var max_scale = max(x_scale, y_scale)
	sprite.set_scale(Vector2(max_scale, max_scale))
