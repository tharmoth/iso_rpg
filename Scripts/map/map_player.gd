extends Node2D

var SPEED = 200
var target_interactable = null
var interaction_range = 50
@onready var navigation_agent = $NavigationAgent2D

func _ready():
	if Party.map_position != Vector2.ZERO:
		position = Party.map_position

func _physics_process(delta):
	
	var velocity = to_local(navigation_agent.get_next_path_position()).normalized() * SPEED
	
	if not navigation_agent.is_navigation_finished():
		position += velocity * delta
#	else:
#		position = target

	# TODO: only update this when needed.
	Party.map_position = position

	if target_interactable != null and position.distance_to(target_interactable.position) < interaction_range:
		target_interactable.interact()

func _unhandled_input(event):
	if Input.is_action_pressed("interact"):
		if GlobalCursor.current_state == GlobalCursor.State.CAN_INTERACT:
			target_interactable = GlobalCursor.highlighted
			navigation_agent.target_position = target_interactable.position
		elif GlobalCursor.current_state == GlobalCursor.State.MOVE:
			navigation_agent.target_position = get_global_mouse_position()
			print(get_global_mouse_position())
