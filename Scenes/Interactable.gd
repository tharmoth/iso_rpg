extends Area2D

var highlighted : bool = false :
	set(value):
		highlighted = value
		update_cursor()

func _on_mouse_entered():
	highlighted = true
	
func _on_mouse_exited():
	highlighted = false
	
func _draw():
	if highlighted:
		draw_polygon($CollisionPolygon2D.polygon, PackedColorArray([Color(0, .5, .5, .3)]))
		
		var outline : PackedVector2Array = $CollisionPolygon2D.polygon
		outline.append($CollisionPolygon2D.polygon[0])
		
		draw_polyline(outline, Color(0, .5, .5, 1), .5, true)
	
func update_cursor():
	if highlighted:
		Cursor.current_state = CursorState.State.CAN_INTERACT
	else:
		Cursor.current_state = CursorState.State.MOVE
	queue_redraw()
	
func _on_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("interact"):
		Cursor.current_state = CursorState.State.INTERACTING
	elif Input.is_action_just_released("interact"):
		update_cursor()
