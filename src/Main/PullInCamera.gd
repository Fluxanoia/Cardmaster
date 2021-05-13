class_name PullInCamera
extends BackedCamera2D

var tween : Tween
var timer : Timer

var dist : Vector2 = Vector2(0, 500)
	
func _ready() -> void:
	var end_pos = self.get_position()
	self.set_position(end_pos + dist)
	tween = Tween.new()
	Globals.error_on_false(tween.interpolate_property(self, 
		"position", null, end_pos, 2, 
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT))
	self.add_child(tween)
	
func play() -> void:
	print()
	Globals.error_on_false(tween.start())
