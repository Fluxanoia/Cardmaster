class_name Main
extends Node

var starting : bool = false

func _ready() -> void:
	var start_button = $CanvasLayer/MainMenu/VBoxContainer/HBoxContainer/Buttons/StartButton
	var quit_button = $CanvasLayer/MainMenu/VBoxContainer/HBoxContainer/Buttons/QuitButton
	Globals.handle_error(start_button.connect("pressed", self, "begin_start"))
	Globals.handle_error(quit_button.connect("pressed", self, "quit"))
	$CanvasLayer/LoadScreen.fade_out(1, $PullInCamera, "play")

func begin_start() -> void:
	if $CanvasLayer/LoadScreen.is_running(): return
	if starting: return
	starting = true
	$CanvasLayer/LoadScreen.fade_in(1, self, "start")
	
func start() -> void:
	Globals.handle_error(get_tree().change_scene("res://src/Map/Map.tscn"))

func quit() -> void:
	if $CanvasLayer/LoadScreen.is_running(): return
	self.get_tree().quit()
