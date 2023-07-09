extends Area2D

var highlighted = false
var selection_color_tween
@onready var circle_color = get_default_color() :
	set(value):
		circle_color = value
		get_parent().circle_color = circle_color

func _ready():
	mouse_entered.connect(_on_mouse_over_mouse_entered)
	mouse_exited.connect(_on_mouse_over_mouse_exited)
	if get_parent() is Player:
		get_parent().selection_changed.connect(func(): circle_color = get_default_color())

func _on_mouse_over_mouse_entered():
	GlobalCursor.mouse_enter(get_parent())


func _on_mouse_over_mouse_exited():
	GlobalCursor.mouse_exit(get_parent())


func set_highlighted(highlight : bool):	
	highlighted = highlight
	if highlighted:
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
	selection_color_tween.tween_property(self, "circle_color", UTILS.HIGHLIGHTED_COLOR, .5)
	selection_color_tween.tween_property(self, "circle_color", get_default_color(), .5)
	selection_color_tween.tween_callback(blink)
	
func get_default_color() -> Color:
	if get_parent() is Player and get_parent().selected:
		return UTILS.SELECTED_COLOR
	elif get_parent() is Player and not get_parent().selected:
		return UTILS.PLAYER_COLOR
	else:
		return UTILS.HOSTILE_COLOR
