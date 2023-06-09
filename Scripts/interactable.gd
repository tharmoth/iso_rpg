extends Area2D

class_name Interactable

var highlighted = false

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func loot(player : BCharacter):
	push_error("Implement me!")

func _on_mouse_entered():
	GlobalCursor.mouse_enter(self)
	
func _on_mouse_exited():
	GlobalCursor.mouse_exit(self)
	
func set_highlighted(highlight : bool):
	highlighted = highlight
	queue_redraw()
	
func _draw():
#	if selected or $CollisionPolygon2D.polygon.size() > 0:
	if highlighted:
		draw_polygon($CollisionPolygon2D.polygon, PackedColorArray([Color(0, .5, .5, .3)]))
		
		var outline : PackedVector2Array = $CollisionPolygon2D.polygon
		outline.append($CollisionPolygon2D.polygon[0])
		
		draw_polyline(outline, Color(0, .5, .5, 1), .5, true)
