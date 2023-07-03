extends CanvasLayer

func _ready():
	%ExitButton.pressed.connect(_on_exit_pressed)
	%ExitButton.button_down.connect($ButtonPressAudioPlayer.play)
	
	
func _on_exit_pressed():
	if $ButtonPressAudioPlayer.playing:
		$ButtonPressAudioPlayer.finished.connect(exit)
	else:
		exit()

func exit():
	GlobalPersistant.save_player()
	GlobalPersistant.change_scene("res://Scenes/ui/start_screen.tscn")
