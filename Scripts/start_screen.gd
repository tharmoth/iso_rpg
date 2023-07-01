extends Control

func _ready():
	%StartButton.connect("button_up", _start_button_pressed)
	

func _start_button_pressed():
	GlobalPersistant.change_scene("res://Scenes/levels/forest.tscn")
