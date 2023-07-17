extends Resource

@export var max_speed := 350
@export var steer_force := .5
@export var look_ahead := 25
@export var num_rays := 64

# context array
var ray_directions : Array[Vector2] = []
var interest : Array[float] = []
var danger : Array[float] = []

var chosen_dir := Vector2.ZERO
var acceleration := Vector2.ZERO
var rotation := Vector2.ZERO
var position := Vector2.ZERO

var owner : Character

var tick_timer := Timer.new()
var cached_dir = Vector2.ZERO

func init(new_owner : Character) -> void:
	owner = new_owner
	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)
	owner.add_child(tick_timer)
	
	tick_timer.wait_time = .25
	tick_timer.one_shot = false
	tick_timer.timeout.connect(_update_cache)
	tick_timer.start()
	
	var ray_angle = PI * 1.5
	
	for i in num_rays:
		var angle = ((i) * ray_angle / (num_rays - 1)) - ray_angle / 2 + PI/8
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
		
func _update_cache():
	cached_dir = chosen_dir


func update() -> Vector2:
	position = owner.position
	rotation = owner.velocity

	set_interest()
	set_danger()
	choose_direction()

	owner.queue_redraw()

	return cached_dir if cached_dir != Vector2.ZERO else chosen_dir
	
func set_interest() -> void:
	# Set interest in each slot based on world direction
#	if owner and owner.has_method("get_path_direction"):

	var target = owner.to_local(owner.get_node("NavigationAgent2D").get_next_path_position())

	var path_direction = rotation
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation.angle()).dot(target)
		interest[i] = max(0, d)
	owner.queue_redraw()	
	

func set_default_interest() -> void:
	# Default to moving forward
	for i in num_rays:
#		var d = ray_directions[i].rotated(rotation).dot(transform.x)
		var d = ray_directions[i].rotated(rotation.angle())
		interest[i] = max(0, d.angle())
		
		
func set_danger() -> void:
	# Cast rays to find danger directions
	var space_state = owner.get_world_2d().direct_space_state
	for i in num_rays:
#		var result = space_state.intersect_ray(position, position + ray_directions[i].rotated(rotation) * look_ahead, [self])
		var params = PhysicsRayQueryParameters2D.new()
		params.from = position
		params.to = position + ray_directions[i].rotated(rotation.angle()) * look_ahead
		var result = space_state.intersect_ray(params)
		danger[i] = 1.0 if result else 0.0
		
		
func choose_direction() -> void:
	# Eliminate interest in slots with danger
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	
	# Choose direction based on remaining interest
	chosen_dir = UTILS.array_sum_vector2(UTILS.array_dot(ray_directions, interest))

	# Find the valid ray closest to the desired direction
	chosen_dir = UTILS.find_closest_ray(UTILS.array_dot(ray_directions, interest), chosen_dir)
	
	chosen_dir = chosen_dir.normalized().rotated(rotation.angle()) * owner.SPEED
