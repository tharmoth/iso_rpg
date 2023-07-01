extends CanvasLayer

func _ready():
	%ExitButton.button_up.connect(exit)
	
func exit():
	GlobalPersistant.save_player()
	get_tree().quit()
