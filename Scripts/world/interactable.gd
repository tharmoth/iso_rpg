extends Area2D

class_name Interactable

var highlighted = false

signal clicked

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func loot(player : BCharacter):
	push_error("Implement me!")

func _on_mouse_entered():
	GlobalCursor.mouse_enter(self)
	
func _on_mouse_exited():
	GlobalCursor.mouse_exit(self)
	
func _unhandled_input(event):
	if GlobalCursor.highlighted == self and Input.is_action_pressed("interact"):
		clicked.emit()
	
func set_highlighted(highlight : bool):
	
	highlighted = highlight
	queue_redraw()
	
func _draw():
#	if selected or $CollisionPolygon2D.polygon.size() > 0:

	if highlighted:
		if not $CollisionPolygon2D.polygon.is_empty():
			draw_polygon($CollisionPolygon2D.polygon, PackedColorArray([Color(0, .5, .5, .3)]))
			
			var outline : PackedVector2Array = $CollisionPolygon2D.polygon
			outline.append($CollisionPolygon2D.polygon[0])
			
			draw_polyline(outline, Color(0, .5, .5, 1), .5, true)
		
		if $CollisionShape2D != null and $CollisionShape2D.shape != null:
			draw_arc(Vector2.ZERO, $CollisionShape2D.shape.radius, 0, 360, 20, Color(0, .5, .5, 1))
			draw_circle(Vector2.ZERO, $CollisionShape2D.shape.radius, Color(0, .5, .5, .3))
