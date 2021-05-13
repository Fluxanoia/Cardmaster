class_name Deck
extends CanvasLayer

const TARGET_WIDTH : int = 1280

var sender : WeakRef = null
var parent : WeakRef = null

var cards : Array = []
var selection : int = 0

func construct(send : Entity = null, par : Node = null) -> void:
	__constructed = true
	self.sender = weakref(send)
	self.parent = weakref(par)

func prepare() -> void:
	Globals.handle_error(
		get_tree().get_root().connect("size_changed", self, "resize"))
	self.resize()
	
var __constructed = false 
func _ready() -> void:
	if not __constructed && self.has_method("construct"):
		self.call("construct")
	if self.has_method("prepare"): self.call("prepare")
	
func add_card(attack : Attack) -> void:
	var card = Card.new()
	card.construct(attack)
	cards.push_back(card)
	card.get_attack().set_ownership(sender, parent)
	self.add_child(card)
	card.set_selected(cards.size() - 1, selection)
	
func cycle_selection(dir : int) -> void:
	if cards.size() == 0: return
	var next_sel = selection + dir
	if next_sel < 0: next_sel = cards.size() - 1
	if next_sel >= cards.size(): next_sel = 0
	selection = next_sel
	for i in range(cards.size()):
		cards[i].set_selected(i, selection)
		
func fire() -> Action:
	if cards.size() == 0: return null
	return cards[selection].get_attack().fire()
	
func resize() -> void:
	var viewport = get_viewport().get_visible_rect().size
	var s = viewport.x / TARGET_WIDTH
	self.set_scale(Vector2(s, s))
	self.set_offset(Vector2(0, viewport.y - CardInfo.CARD_SIZE.y * s * 0.8))
