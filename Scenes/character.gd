extends CharacterBody2D

const SPEED = 150.0

enum EastWestFacing {EAST, NONE, WEST}
var current_east_west_facing := EastWestFacing.NONE

enum NorthSouthFacing {NORTH, NONE, SOUTH}
var current_north_south_facing := NorthSouthFacing.NONE

var current_facing := "SOUTH" :
	set(value):
		current_facing = value
		_update_animation()

enum State {IDLE, RUN}
var current_state = State.IDLE:
	set(value):
		current_state = value
		_update_animation()


func _update_animation():
	var animation = State.keys()[current_state] + "_" + current_facing
	$AnimationPlayer.play(animation)

func _ready():
	current_state = current_state
	$NavigationAgent2D.velocity_computed.connect(_on_nav_velocity_computed)
	
func _on_nav_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _physics_process(delta) -> void:
	
	_update_facing()
	_update_state()
	
	if not $NavigationAgent2D.is_navigation_finished():
		$NavigationAgent2D.set_velocity(to_local($NavigationAgent2D.get_next_path_position()).normalized() * SPEED)
		move_and_slide()
	else:
		velocity = Vector2(0, 0)
	
	# _process_input()

func _input(event):
	# Mouse in viewport coordinates.
	if event is InputEventMouseButton and event.is_pressed():
		$NavigationAgent2D.target_position = get_global_mouse_position()

func _update_state() -> void:
	if velocity.length() > 0 and current_state != State.RUN:
		current_state = State.RUN
	elif velocity.length() == 0 && current_state != State.IDLE: 
		current_state = State.IDLE
		
func _update_facing() -> void:
	if velocity.length() == 0:
		return
	
	var angle = rad_to_deg(velocity.angle()) + 180
	var sweep = 67.5

	if sweep > angle - 180 and angle - 180 > -sweep:
		current_east_west_facing = EastWestFacing.EAST
	elif angle > 360 - sweep or angle < sweep:
		current_east_west_facing = EastWestFacing.WEST
	elif abs(velocity.y) > 0:
		current_east_west_facing = EastWestFacing.NONE

	if sweep > angle - 270 and angle - 270 > -sweep:
		current_north_south_facing = NorthSouthFacing.SOUTH
	elif sweep > angle - 90 and angle - 90 > -sweep:
		current_north_south_facing = NorthSouthFacing.NORTH
	elif abs(velocity.x) > 0:
		current_north_south_facing = NorthSouthFacing.NONE	

	var temp_facing = ""
	if current_north_south_facing != NorthSouthFacing.NONE:
		temp_facing = NorthSouthFacing.keys()[current_north_south_facing]
	
	if current_east_west_facing != EastWestFacing.NONE:
		if temp_facing != "":
			temp_facing += "_"
		temp_facing += EastWestFacing.keys()[current_east_west_facing]
		
	if temp_facing == "":
		temp_facing = "SOUTH"
		
	if temp_facing != current_facing:
		current_facing = temp_facing
		
func _process_input() -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	direction = Input.get_axis("ui_up", "ui_down")
	if direction:
		velocity.y = direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
