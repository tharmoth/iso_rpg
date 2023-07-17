extends Node2D

class_name CursorState

enum State {MOVE, ATTACK, CAN_INTERACT, INTERACTING}
var current_state : State = State.MOVE : set = _set_state

var mouse_over_queue : Array = []

func mouse_enter(object) -> void:
	mouse_over_queue.push_front(object)
	highlighted = mouse_over_queue.front()
	
func mouse_exit(object) -> void:
	if mouse_over_queue.find(object) > -1:
		mouse_over_queue.remove_at(mouse_over_queue.find(object))
		
	if mouse_over_queue.size() > 0:
		highlighted = mouse_over_queue.front()
	else:
		highlighted = null

var highlighted : Node2D = null : 
	set(value):
		if highlighted != null and highlighted.has_method("set_highlighted"):
			highlighted.set_highlighted(false)
			
		highlighted = value
		
		if highlighted != null and highlighted.has_method("set_highlighted"):
			highlighted.set_highlighted(true)
		
		if (highlighted is Interactable or (highlighted is BCharacter and not highlighted.alive)) and current_state == State.CAN_INTERACT:
			current_state = State.INTERACTING
		elif highlighted is Interactable or (highlighted is BCharacter and not highlighted.alive):
			current_state = State.CAN_INTERACT
		elif highlighted is BCharacter and not highlighted is Player:
			current_state = State.ATTACK
		else:
			current_state = State.MOVE

var dragging = false  # Are we currently dragging?
var drag_start = Vector2.ZERO  # Location where drag began.
var select_rect = RectangleShape2D.new()  # Collision shape for drag box.	
	
func _unhandled_input(event):
	# is_action_just_pressed not working for simulated inputs? so we reimplement it here!
	if Input.is_action_pressed("move"):
		Input.action_release("move")
	
	if Input.is_action_just_pressed("interact"):
		drag_start = get_global_mouse_position()
			
	elif Input.is_action_pressed("interact"):
		if get_global_mouse_position().distance_to(drag_start) > 10:
			dragging = true
		if dragging:
			queue_redraw()
			
	if Input.is_action_just_released("interact"):
		if dragging:
			_drag_release()
		else:
			Input.action_press("move")

# Button released while dragging.
func _drag_release():
	dragging = false
	queue_redraw()
	
	
	var drag_end = get_global_mouse_position()
	select_rect.extents = abs((drag_end - drag_start) / 2)
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(select_rect)
	query.transform = Transform2D(0, (drag_end + drag_start) / 2)
	
		
	var party_leaders = []
	for shape in space.intersect_shape(query):
		var body = shape["collider"]
		if body is Player:
			party_leaders.append(body)

	if not party_leaders.is_empty():
		for player in Party.players:
			player.selected = party_leaders.find(player) != -1

func _draw():
	if dragging:
		var fill_color = UTILS.PLAYER_COLOR
		fill_color.a = .25
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start),
		UTILS.PLAYER_COLOR, false)
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start),
		fill_color, true)

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_state(State.MOVE)
	tree_entered.connect(reset)
	tree_exited.connect(reset)
	
func reset():
	mouse_over_queue.clear()
	highlighted = null

func _physics_process(delta):
	if Input.is_action_just_pressed("interact") or Input.is_action_just_released("interact"):
		highlighted = highlighted

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
