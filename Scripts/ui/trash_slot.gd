extends TextureRect

func _can_drop_data(at_position, data):
	return true
	
func _drop_data(at_position, data):
	data["origin"].item_name = ""
	GUI.get_node("%Inventory").data = null
