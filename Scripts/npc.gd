extends "res://Scripts/character.gd"

class_name NPC

func _ready():
	super()
	target = get_parent().get_node("Player")
	fight_timer.start()
	_wander()
	circle_color = Color(.7, .1, .1)
	$SelectionArea.mouse_entered.connect(_on_mouse_over_mouse_entered)
	$SelectionArea.mouse_exited.connect(_on_mouse_over_mouse_exited)

func _update_state() -> void:
	pass

func _on_mouse_over_mouse_entered():
	circle_color = Color(1, 1, 1)
	GlobalCursor.selected = self

func _on_mouse_over_mouse_exited():
	circle_color = Color(.7, .1, .1)
	GlobalCursor.selected = null

