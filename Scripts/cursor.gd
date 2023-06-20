extends Node

class_name CursorState

enum State {MOVE, ATTACK, CAN_INTERACT, INTERACTING}
var current_state : State = State.MOVE : set = _set_state

var mouse_over_queue : Array = []

func mouse_enter(object) -> void:
	mouse_over_queue.push_front(object)
	selected = mouse_over_queue.front()
	
func mouse_exit(object) -> void:
	mouse_over_queue.remove_at(mouse_over_queue.find(object))
	selected = mouse_over_queue.front()

var selected : Node2D = null : 
	set(value):
		
		if selected != null and selected.has_method("set_selected"):
			selected.set_selected(false)
			
		selected = value
		
		if selected != null and selected.has_method("set_selected"):
			selected.set_selected(true)
		
		if selected is Interactable and current_state == State.CAN_INTERACT:
			current_state = State.INTERACTING
		elif selected is Interactable:
			current_state = State.CAN_INTERACT
		elif selected is NPC:
			current_state = State.ATTACK
		else:
			current_state = State.MOVE

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_state(State.MOVE)
	
func _physics_process(delta):
	if Input.is_action_just_pressed("interact") or Input.is_action_just_released("interact"):
		selected = selected

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
