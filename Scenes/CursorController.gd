extends Node2D

var pointing = load("res://Assets/Cursors/pointing.png")
var can_grab = load("res://Assets/Cursors/can_grab.png")
var grabbing = load("res://Assets/Cursors/grabbing.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(pointing)
