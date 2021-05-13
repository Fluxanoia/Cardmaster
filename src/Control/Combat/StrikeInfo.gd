class_name StrikeInfo
extends Resource

# The object tied to this information
var source : WeakRef = null
# Whether the source should become an
# exception once it has struck
var oneshot : bool = true

var damage    : float = 0.0
var knockback : float = 0.0
# Whether this strike stops actions
var stops     : bool = false

# Override the base knockback response with a
# custom angle
var knockback_angle_override : bool = false
var knockback_angle          : float = 0.0
