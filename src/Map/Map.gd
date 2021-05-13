class_name Map
extends Node2D

var backing_out : bool = false

var camera : BackedCamera2D
var player : Player

func _ready() -> void:
	$CanvasLayer/LoadScreen.fade_out(0, null, "")
	camera = BackedCamera2D.new()
	camera.construct(load("res://images/tileset/forest/bg.png"))
	camera._set_current(true)
	player = EntityInfo.get_actor(EntityInfo.ActorType.PLAYER)
	player.set_module_code(EntityInfo.ControlType.PLAYER)
	player.add_to_group(EntityInfo.PLAYER_GROUP)
	player.set_z_index(1)
	player.add_child(camera)
	self.add_child(player)
	
func _physics_process(_delta : float) -> void:
	camera.process_shake()
	if $CanvasLayer/LoadScreen.is_running(): return
	if Input.is_key_pressed(KEY_ESCAPE) || player.is_dead():
		if backing_out: return
		backing_out = true
		$CanvasLayer/LoadScreen.fade_in(1, self, "back_to_menu")
		
func back_to_menu() -> void:
	Globals.handle_error(get_tree().change_scene("res://src/Main/Main.tscn"))
