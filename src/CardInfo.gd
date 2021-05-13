extends Node

# The beginning and end of card paths
const TEXTURE_PATH = "res://images/cards/"
const TEXTURE_TYPE = ".png"
const AUDIO_PATH = "res://audio/sfx/card/"
const AUDIO_TYPE = ".ogg"

const CARD_THROW_PATHS = ["cardSlide1", "cardSlide2", "cardSlide3",
	"cardSlide4", "cardSlide5", "cardSlide6", "cardSlide7", "cardSlide8"]
const CARD_HIT_PATHS = ["cardShove1", "cardShove2", "cardShove3","cardShove4"]

# The dimensions of the card images
const CARD_SIZE = Vector2(140, 190)

# The different card suits
enum CardSuit { NONE, CLUBS, HEARTS, DIAMONDS, SPADES }
# The different card values
enum CardValue {
	JOKER, ACE, ONE, TWO, THREE, FOUR, FIVE, SIX, 
	SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING
}

# The different card colours
enum CardBackColour { RED, GREEN, BLUE }
# The different card styles
enum CardBackStyle { PLAIN = 1, PATTERN_FILL, BORDER, PATTERN, CENTER }
# The counter for the number of colours and styles
const CARD_COLOUR_COUNT = 3
const CARD_STYLE_COUNT = 5

# The audio streams
var card_throws : Array = []
var card_hits : Array = []

# The card textures
var joker    : Texture = null
var clubs    : Array = []
var hearts   : Array = []
var diamonds : Array = []
var spades   : Array = []
var backs    : Array = []

# Loads all the card textures
func _ready() -> void:
	joker = load(get_front_texture_path(CardValue.JOKER, CardSuit.NONE))
	for i in range(CardValue.ACE, CardValue.KING): 
		clubs.push_back(load(get_front_texture_path(i, CardSuit.CLUBS)))
		hearts.push_back(load(get_front_texture_path(i, CardSuit.HEARTS)))
		diamonds.push_back(load(get_front_texture_path(i, CardSuit.DIAMONDS)))
		spades.push_back(load(get_front_texture_path(i, CardSuit.SPADES)))
	for i in range(0, CARD_COLOUR_COUNT):
		var list = []
		for j in range(1, CARD_STYLE_COUNT + 1):
			list.push_back(load(get_back_texture_path(i, j)))
		backs.push_back(list)
	for s in CARD_THROW_PATHS:
		card_throws.push_back(load(AUDIO_PATH + s + AUDIO_TYPE))
	for s in CARD_HIT_PATHS:
		card_hits.push_back(load(AUDIO_PATH + s + AUDIO_TYPE))
		
# Returns a random throw sound
func get_random_card_throw() -> AudioStream:
	return card_throws[randi() % card_throws.size()]
		
# Returns a random hit sound
func get_random_card_hit() -> AudioStream:
	return card_hits[randi() % card_hits.size()]

# Returns the texture corresponding to the given value and suit
func get_card_face(value : int, suit : int) -> Texture:
	if value < CardValue.JOKER || value > CardValue.KING:
		push_error("Unknown card value in get_card_face.")
	if value == CardValue.JOKER: return joker
	if suit == CardSuit.CLUBS: return clubs[value]
	if suit == CardSuit.HEARTS: return hearts[value]
	if suit == CardSuit.DIAMONDS: return diamonds[value]
	if suit == CardSuit.SPADES: return spades[value]
	push_error("Unknown suit in get_card_face.")
	return null
	
# Returns the texture corresponding to the given colour and style
func get_card_back(colour : int, style : int) -> Texture:
	if colour < 0 || colour >= CARD_COLOUR_COUNT:
		push_error("Unknown colour in get_card_back.")
		return null
	if style < 0 || style >= CARD_STYLE_COUNT:
		push_error("Unknown style in get_card_back.")
		return null
	return backs[colour][style]

# Returns a random card face
func get_random_card_front() -> Texture:
	var s = randi() % (13 * 4 + 1)
	if s == 0: return joker
	s -= 1
	if s < 13: return clubs[s]
	s -= 13
	if s < 13: return hearts[s]
	s -= 13
	if s < 13: return diamonds[s]
	s -= 13
	return spades[s]
	
# Returns a random card back
func get_random_card_back() -> Texture:
	return backs[randi() % CARD_COLOUR_COUNT][randi() % CARD_STYLE_COUNT]
		
# Returns the path to the corresponding face texture
func get_front_texture_path(value : int, suit : int) -> String:
	var path = TEXTURE_PATH
	if suit != CardSuit.NONE:
		path += get_suit_name(suit) + "_"
	path += get_value_name(value)
	path += TEXTURE_TYPE
	return path
	
# Returns the path to the corresponding back texture
func get_back_texture_path(colour : int, style : int) -> String:
	var path = TEXTURE_PATH
	path += "back_"
	path += get_colour_name(colour) + "_"
	path += get_style_name(style)
	path += TEXTURE_TYPE
	return path
	
# Returns the string corresponding to the given value
func get_value_name(value : int) -> String:
	if value == CardValue.JOKER: return "joker"
	if value > CardValue.JOKER && value <= CardValue.KING: 
		return str(value)
	push_error("Unknown card value in get_value_name.")
	return "none"
	
# Returns the string corresponding to the given suit
func get_suit_name(suit : int) -> String:
	if suit == CardSuit.CLUBS: return "clubs"
	if suit == CardSuit.HEARTS: return "hearts"
	if suit == CardSuit.DIAMONDS: return "diamonds"
	if suit == CardSuit.SPADES: return "spades"
	if suit == CardSuit.NONE: return "none"
	push_error("Unknown suit value in get_suit_name.")
	return "none"
	
# Returns the string corresponding to the given colour
func get_colour_name(c : int) -> String:
	if c == CardBackColour.RED: return "red"
	if c == CardBackColour.GREEN: return "green"
	if c == CardBackColour.BLUE: return "blue"
	push_error("Unknown colour value in get_colour_name.")
	return "none"
	
# Returns the style corresponding to the given style
func get_style_name(style : int) -> String:
	if style <= 0 || style > CARD_STYLE_COUNT:
		push_error("Unknown style value in get_style_name.")
		return "none"
	return str(style)
	
