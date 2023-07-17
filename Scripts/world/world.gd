extends Node2D

var camera = RTSCam.new()

func _ready():
	camera.use_mouse = false
	camera.follow_object = $MapPlayer
	add_child(camera)

#	Party.load_party()
	GUI.visible = true
