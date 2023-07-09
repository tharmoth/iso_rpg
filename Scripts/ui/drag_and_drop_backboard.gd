extends Control

func _can_drop_data(at_position, data):
	return true
	
func _drop_data(at_position, data):
	print("resetting!")
	data["reset"].call()

