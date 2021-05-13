class_name Action
extends Resource

# The length of the action in physics frames
var length : int = 0

# The frames at which "callback" is called on the callback object
var callback_frames : Array = []
# The object which has "callback", "cancelled" and "finished" called on it
var callback : WeakRef = null

# The frames that attacks are sent out on, for animation purposes only
var attack_frames : Array = []

# The strike done unto the action bearer
# at acquisition
var self_strike : StrikeInfo = null

# Whether the entity's direction should be locked
var lock_direction : bool = false
# The Globals.Side direction the entity should face
var locked_direction = null

# Whether this action can be stopped by stopping strikes
var stoppable : bool = true

# Whether the restrictions act as an allowlist
var allowlist : bool = false
# The controls that are restricted/whitelisted
var restrict : Array = []
# The length of the restriction/whitelist
var restrict_length : int = 0

# Controls that can cancel the action completely
var cancels : Array = []
# Controls that can cancel the animation
var anim_cancels : Array = []
