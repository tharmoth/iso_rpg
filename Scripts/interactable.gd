extends Area2D

class_name Interactable

var selected := false

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_entered.connect(_on_mouse_exited)

func loot(player : Character):
	push_error("Implement me!")

func _on_mouse_entered():
	GlobalCursor.mouse_enter(self)
	
func _on_mouse_exited():
	GlobalCursor.mouse_exit(self)
	
func set_selected(select : bool):
	selected = select
	queue_redraw()
	
func _draw():
	if selected:
		draw_polygon($CollisionPolygon2D.polygon, PackedColorArray([Color(0, .5, .5, .3)]))
		
		var outline : PackedVector2Array = $CollisionPolygon2D.polygon
		outline.append($CollisionPolygon2D.polygon[0])
		
		draw_polyline(outline, Color(0, .5, .5, 1), .5, true)
