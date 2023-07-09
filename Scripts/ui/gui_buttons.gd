extends Control

func _ready():
	%ExitButton.pressed.connect(_on_exit_pressed)
	%ExitButton.button_down.connect($ButtonPressAudioPlayer.play)
	
	%InventoryButton.toggled.connect(_on_gear_pressed)
	%InventoryButton.button_down.connect($ButtonPressAudioPlayer.play)
	%InventoryButton.set_pressed_no_signal(get_tree().current_scene.name == "Inventory")
	
	%CameraButton.toggled.connect(camera)
	%CameraButton.button_down.connect($ButtonPressAudioPlayer.play)
#	%CameraButton.set_pressed_no_signal(GlobalPersistant.lock_camera)
	
func _on_exit_pressed():
	if $ButtonPressAudioPlayer.playing:
		$ButtonPressAudioPlayer.finished.connect(exit)
	else:
		exit()

func exit():
	$ButtonPressAudioPlayer.finished.disconnect(exit)
	GlobalPersistant.save_player()
	GlobalPersistant.change_scene("res://Scenes/ui/start_screen.tscn")
	
func _on_gear_pressed(toggled):
	if $ButtonPressAudioPlayer.playing:
		$ButtonPressAudioPlayer.finished.connect(gear)
	else:
		gear()

func gear():
	$ButtonPressAudioPlayer.finished.disconnect(gear)
	if %InventoryButton.button_pressed:
		for node in get_tree().get_nodes_in_group("Inventory"):
			if node.has_method("refresh"):
				node.refresh()
				
		GUI.get_node("%Inventory").visible = true
		get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		GUI.get_node("%Inventory").visible = false
		get_tree().current_scene.process_mode = Node.PROCESS_MODE_ALWAYS
		
func camera(toggled):
	GlobalPersistant.lock_camera = toggled
