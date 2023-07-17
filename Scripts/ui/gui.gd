extends CanvasLayer

@onready var button_player = $ButtonPlayer

func post(text : String) -> void:
	%Console.text = %Console.text + text.replace("_", " ") + "\n"
	%Console.scroll_to_line(%Console.get_line_count()-1)
	print(text)
