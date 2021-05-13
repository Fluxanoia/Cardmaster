class_name GravityParams
extends Resource

var JUMP_MAX_TIME      : float = 0.4    # Max partial jump length
var JUMP_STRENGTH      : float = -300.0 # Jump speed
var TERMINAL_VELOCITY  : float = -600.0 # Maximum falling speed
var MAX_FLY            : float = 500    # Maximum upward speed

var GROUND_SPEED_DECAY : float = 0.6   # Horizontal speed decay on ground
var AIR_SPEED_DECAY    : float = 0.95  # Horizontal speed decay in air
var ACCELERATION       : float = 35.0  # Horizontal acceleration
var MAX_SPEED          : float = 300.0 # Max horizontal speed

var EXTREME_AIR_DECAY    : float = 0.95 # The decay of speed over the max in air
var EXTREME_GROUND_DECAY : float = 0.6 # The decay of speed over the max on the ground
