extends Area2D

var selection_color_tween
@onready var circle_color = get_default_color() :
	set(value):
		circle_color = value
		get_parent().circle_color = circle_color

func _ready():
	mouse_entered.connect(_on_mouse_over_mouse_entered)
	mouse_exited.connect(_on_mouse_over_mouse_exited)

func _on_mouse_over_mouse_entered():
	GlobalCursor.mouse_enter(get_parent())


func _on_mouse_over_mouse_exited():
	GlobalCursor.mouse_exit(get_parent())


func set_selected(select : bool):	
	if select:
		get_parent().get_node("Sprites/Base").set_material(load("res://shaders/outline_material.tres"))
		selection_color_tween = create_tween()
		blink()
	else:
		get_parent().get_node("Sprites/Base").set_material(null)
		if selection_color_tween:
			selection_color_tween.kill()
		circle_color = get_default_color()


func blink() -> void:
	if selection_color_tween:
		selection_color_tween.kill() # Abort the previous animation.
	selection_color_tween = create_tween()
	selection_color_tween.tween_property(self, "circle_color", UTILS.SELECTED_COLOR, .5)
	selection_color_tween.tween_property(self, "circle_color", get_default_color(), .5)
	selection_color_tween.tween_callback(blink)
	
func get_default_color() -> Color:
	return UTILS.PLAYER_COLOR if get_parent() is Player else UTILS.HOSTILE_COLOR
