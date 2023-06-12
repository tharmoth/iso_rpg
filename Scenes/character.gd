extends CharacterBody2D

const SPEED = 150.0

var click_circle = 0
const CIRLCE_SIZE = 22

var saved_state = "Idle"
var target_state = "Idle"

@onready var animation_state : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

func _draw():
	draw_set_transform(Vector2(0, 0), 0, Vector2(1, .5))
	draw_arc(Vector2(0, 0), CIRLCE_SIZE, 0, 360, 100, Color(.1, .7, .1))

func _ready():
	$AnimationTree.active = true
	animation_state.travel("Idle")
	$NavigationAgent2D.velocity_computed.connect(_on_nav_velocity_computed)
	
func _on_nav_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _physics_process(delta) -> void:

	if velocity != Vector2(0, 0):
		$AnimationTree.set("parameters/Idle/blend_position", velocity.normalized())
		$AnimationTree.set("parameters/Walk/blend_position", velocity.normalized())
		$AnimationTree.set("parameters/Attack/Rotate/blend_position", velocity.normalized().x)
		$AnimationTree.set("parameters/Interact/Rotate/blend_position", velocity.normalized().x)
		# $AnimationTree.set("parameters/Attack/ATTACK_SWING_1H/blend_position", velocity.normalized())
	
	if animation_state.get_current_node() == "Walk":
		_process_movement()
		
	_update_state()

func _process_movement() -> void:
	if not $NavigationAgent2D.is_navigation_finished() :
		$NavigationAgent2D.set_velocity(to_local($NavigationAgent2D.get_next_path_position()).normalized() * SPEED)
		move_and_slide()
	else:
		velocity = Vector2(0, 0)
		animation_state.travel(target_state)

func _update_state():
	push_error("_update_state not implemented!")
		
func _on_state_change(new_state):
	pass
	
