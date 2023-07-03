extends TextureRect

func _get_drag_data(at_position):
	
	var data = {}
	
	var drag_texture = TextureRect.new()
	drag_texture.expand = true
	drag_texture.texture = texture
	drag_texture.size = size
	
	var control = Control.new()
	control.add_child(drag_texture)
	drag_texture.position = -0.5 * drag_texture.size
#	drag_texture.offset_bottom = drag_texture.size.y / 2
#	drag_texture.offset_right = drag_texture.size.x / 2
	
	set_drag_preview(control)
	
	return data
	

func _can_drop_data(at_position, data):
	return true
	
func _drop_data(at_position, data):
	pass
