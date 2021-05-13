class_name LoadScreen
extends Sprite

var tween : Tween
var timer : Timer

var waiting_pause   : float
var buffered_method : String
var buffered_args   : Array

var callback : Object
var callback_method : String

func _ready() -> void:
	self.set_centered(false)
	self.set_texture(preload("res://config/fluxanoia_games.png"))
	tween = Tween.new()
	timer = Timer.new()
	timer.set_one_shot(true)
	Globals.handle_error(tween.connect("tween_all_completed", self, "tweened"))
	Globals.handle_error(timer.connect("timeout", self, "perform"))
	self.add_child(tween)
	self.add_child(timer)
	Globals.handle_error(
		get_tree().get_root().connect("size_changed", self, "resize"))
	self.resize()
	
func fade_out(pause : float, cb : Object, 
		cbm : String) -> void:
	if pause > 0: 
		buffered_method = "fade_out"
		buffered_args = [0, cb, cbm]
		timer.start(pause)
		return
	modulate.a = 1
	Globals.error_on_false(tween.remove_all())
	Globals.error_on_false(tween.interpolate_property(self, 
		"modulate:a", 1, 0, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT))
	self.set_callback(cb, cbm)
	Globals.error_on_false(tween.start())
		
func fade_in(pause : float, cb : Object, 
		cbm : String) -> void:
	modulate.a = 0	
	Globals.error_on_false(tween.remove_all())
	Globals.error_on_false(tween.interpolate_property(self, 
		"modulate:a", 0, 1, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT))
	self.set_callback(cb, cbm)
	waiting_pause = pause
	Globals.error_on_false(tween.start())
	
func tweened() -> void:
	if waiting_pause > 0:
		buffered_method = "tweened"
		buffered_args = []
		timer.start(waiting_pause)
		waiting_pause = 0
		return
	if callback != null && callback.has_method(callback_method):
		callback.call(callback_method)
	
func perform() -> void:
	self.callv(buffered_method, buffered_args)
	
func set_callback(cb : Object, cbm : String) -> void:
	self.callback = cb
	self.callback_method = cbm
	
func is_running() -> bool:
	return tween.is_active() || !timer.is_stopped()
	
func resize() -> void:
	var viewport = get_viewport_rect()
	var tex = self.get_texture()
	var x_scale = viewport.size.x / tex.get_width()
	var y_scale = viewport.size.y / tex.get_height()
	self.set_scale(Vector2(x_scale, y_scale))

