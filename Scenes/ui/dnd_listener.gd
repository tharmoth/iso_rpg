extends MarginContainer

var data

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() == false:
		if data != null:
			data["reset"].call()
