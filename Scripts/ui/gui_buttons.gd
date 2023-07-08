extends Control

func _ready():
	%ExitButton.pressed.connect(_on_exit_pressed)
	%ExitButton.button_down.connect($ButtonPressAudioPlayer.play)
	
	%InventoryButton.pressed.connect(_on_gear_pressed)
	%InventoryButton.button_down.connect($ButtonPressAudioPlayer.play)
	%InventoryButton.set_pressed_no_signal(get_tree().current_scene.name == "Inventory")
	
	%CameraButton.pressed.connect(_on_camera_pressed)
	%CameraButton.button_down.connect($ButtonPressAudioPlayer.play)
	%CameraButton.set_pressed_no_signal(GlobalPersistant.lock_camera)
	
func _on_exit_pressed():
	if $ButtonPressAudioPlayer.playing:
		$ButtonPressAudioPlayer.finished.connect(exit)
	else:
		exit()

func exit():
	$ButtonPressAudioPlayer.finished.disconnect(exit)
	GlobalPersistant.save_player()
	GlobalPersistant.change_scene("res://Scenes/ui/start_screen.tscn")
	
func _on_gear_pressed():
	if $ButtonPressAudioPlayer.playing:
		$ButtonPressAudioPlayer.finished.connect(gear)
	else:
		gear()

func gear():
	$ButtonPressAudioPlayer.finished.disconnect(gear)
	if GlobalPersistant.player.spawn_scene != null:
		GlobalPersistant.gui.get_node("%Buttons/%InventoryButton").set_pressed_no_signal(false)
		GlobalPersistant.change_scene(GlobalPersistant.player.spawn_scene)
	else:
		GlobalPersistant.player.spawn_scene = get_tree().current_scene.scene_file_path
		GlobalPersistant.change_scene("res://Scenes/ui/inventory.tscn")
	
func _on_camera_pressed():
	camera()
#	if $ButtonPressAudioPlayer.playing:
#		$ButtonPressAudioPlayer.finished.connect(camera)
#	else:
#		camera()
		
func camera():
	GlobalPersistant.lock_camera = %CameraButton.button_pressed
