extends Control

func _ready():
	%NewButton.pressed.connect(_on_new_pressed)
	%NewButton.button_down.connect($ButtonPressAudioPlayer.play)
	
	%LoadButton.pressed.connect(_on_load_pressed)
	%LoadButton.button_down.connect($ButtonPressAudioPlayer.play)
	
	%ExitButton.pressed.connect(_on_exit_pressed)
	%ExitButton.button_down.connect($ButtonPressAudioPlayer.play)


#################
# New Functions #
#################
func _on_new_pressed():
	if $ButtonPressAudioPlayer.playing:
		$ButtonPressAudioPlayer.finished.connect(new_game)
	else:
		new_game()


func new_game():
	var dir = DirAccess.open("user://")
	for file in dir.get_files():
		dir.remove(file)

	GlobalPersistant.reset()
	GlobalPersistant.change_scene("res://Scenes/levels/forest.tscn")


##################
# Load Functions #
##################
func _on_load_pressed():
	if $ButtonPressAudioPlayer.playing:
		$ButtonPressAudioPlayer.finished.connect(load_game)
	else:
		load_game()


func load_game():
	GlobalPersistant.load_player()
	if GlobalPersistant.player.spawn_scene != null and GlobalPersistant.player.spawn_scene != "":
		GlobalPersistant.change_scene(GlobalPersistant.player.spawn_scene)
	else:
		GlobalPersistant.change_scene("res://Scenes/levels/forest.tscn")


##################
# Exit Functions #
##################
func _on_exit_pressed():
	if $ButtonPressAudioPlayer.playing:
		$ButtonPressAudioPlayer.finished.connect(quit)
	else:
		quit()


func quit():
	get_tree().quit()

