extends Area2D

class_name Interactable

func _on_mouse_entered():
	GlobalCursor.selected = self
	queue_redraw()
	
func _on_mouse_exited():
	GlobalCursor.selected = null
	queue_redraw()
	
func _draw():
	if GlobalCursor.selected == self:
		draw_polygon($CollisionPolygon2D.polygon, PackedColorArray([Color(0, .5, .5, .3)]))
		
		var outline : PackedVector2Array = $CollisionPolygon2D.polygon
		outline.append($CollisionPolygon2D.polygon[0])
		
		draw_polyline(outline, Color(0, .5, .5, 1), .5, true)
