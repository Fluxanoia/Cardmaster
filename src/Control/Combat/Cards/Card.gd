class_name Card
extends Sprite

const CARD_BUFFER = 20
const SHUFFLE_DURATION = 0.3

var index    : int = 0
var selected : bool = false

var tween  : Tween = null
var attack : Attack = null

######################
### Initialisation ###
######################

func construct(a : Attack) -> void:
	__constructed = true
	attack = a
	tween = Tween.new()
	self.add_child(tween)
	self.set_texture(a.get_card_texture())
	self.set_centered(false)

var __constructed = false 
func _ready() -> void:
	if not __constructed && self.has_method("construct"):
		self.call("construct")
	if self.has_method("prepare"): self.call("prepare")

func set_selected(i : int, selected_index : int) -> void:
	self.index = i
	self.selected = i == selected_index
	var x = CARD_BUFFER * (i + 1)
	var y = -(CardInfo.CARD_SIZE.y + CARD_BUFFER) if selected else 0.0
	Globals.error_on_false(tween.remove_all())
	Globals.error_on_false(tween.interpolate_property(self, 
		"position", null, Vector2(x, y), SHUFFLE_DURATION, 
		Tween.TRANS_QUAD, Tween.EASE_IN))
	Globals.error_on_false(tween.start())
	
func get_attack() -> Attack:
	return attack
