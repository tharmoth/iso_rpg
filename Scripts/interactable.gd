extends Area2D

class_name Interactable

var selected := false

enum ACTIONS {LOOT, MAP}

@export var action : ACTIONS
@export var item : Items.ITEM_NAME
@export var scene : String
@export var scene_start : Vector2

func loot(player : Character):
	if action == ACTIONS.MAP:
		get_tree().change_scene_to_file(scene)
	else:
		queue_free()
		GlobalCursor.mouse_exit(self)
		return Items.items.get(item)

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
