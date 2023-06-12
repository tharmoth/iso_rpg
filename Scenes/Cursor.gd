extends Node

class_name CursorState

enum State {MOVE, ATTACK, CAN_INTERACT, INTERACTING}
var current_state : State = State.MOVE : set = _set_state

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_state(State.MOVE)

func _set_state(value) -> void:
	current_state = value
	if current_state == State.MOVE:
		Input.set_custom_mouse_cursor(load("res://Assets/Cursors/pointing.png"))
	elif current_state == State.CAN_INTERACT:
		Input.set_custom_mouse_cursor(load("res://Assets/Cursors/can_grab.png"))
	elif current_state == State.INTERACTING:
		Input.set_custom_mouse_cursor(load("res://Assets/Cursors/grabbing.png"))
	elif current_state == State.ATTACK:
		Input.set_custom_mouse_cursor(load("res://Assets/Cursors/sword.png"))
