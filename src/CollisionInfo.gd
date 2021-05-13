extends Node

# The layers used for the different types of collision
const MAIN_COLLISION_BIT       : int = 0
const DROPTHRU_COLLISION_BIT   : int = 4

# The size of tiles in the game
const TILE_SIZE : int = 16

#################
### Collision ###
#################

# Checks for collisions against a shape in a given world
func query_world_shape_intersect(world : World2D, 
		shape : Shape2D, position : Vector2,
		collision_layer : int = CollisionInfo.MAIN_COLLISION_BIT + 1) -> bool:
	var params = Physics2DShapeQueryParameters.new()
	params.set_shape(shape)
	params.set_transform(Transform2D(0, position))
	params.set_collision_layer(collision_layer)
	var space_state = world.get_direct_space_state()
	return space_state.intersect_shape(params, 1).size() > 0
