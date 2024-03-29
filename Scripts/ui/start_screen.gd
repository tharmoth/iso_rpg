extends Control

func _ready():
	%NewButton.pressed.connect(_on_new_pressed)
	%NewButton.button_down.connect($ButtonPressAudioPlayer.play)
	
	%LoadButton.pressed.connect(_on_load_pressed)
	%LoadButton.button_down.connect($ButtonPressAudioPlayer.play)
	
	%ExitButton.pressed.connect(_on_exit_pressed)
	%ExitButton.button_down.connect($ButtonPressAudioPlayer.play)
	
	GUI.visible = false
	GUI.get_node("%DeathLabel").visible = false


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

	Party.players = Party.get_new_party()
	Party.change_scene("res://Scenes/levels/world.tscn")


##################
# Load Functions #
##################
func _on_load_pressed():
	if $ButtonPressAudioPlayer.playing:
		$ButtonPressAudioPlayer.finished.connect(load_game)
	else:
		load_game()


func load_game():
	Party.load_party()
	get_tree().change_scene_to_file(Party.scene)


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

