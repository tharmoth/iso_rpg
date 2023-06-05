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
	

func _physics_process(delta) -> void:
	_process_input()
	_update_facing()
	_update_state()

	move_and_slide()

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
	
func _update_state() -> void:
	if velocity.length() > 0 and current_state != State.RUN:
		current_state = State.RUN
	elif velocity.length() == 0 && current_state != State.IDLE: 
		current_state = State.IDLE
		
func _update_facing() -> void:
	if velocity.x > 0:
		current_east_west_facing = EastWestFacing.EAST
	elif velocity.x < 0:
		current_east_west_facing = EastWestFacing.WEST
	elif abs(velocity.y) > 0:
		current_east_west_facing = EastWestFacing.NONE
		
	if velocity.y > 0:
		current_north_south_facing = NorthSouthFacing.SOUTH
	elif velocity.y < 0:
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
