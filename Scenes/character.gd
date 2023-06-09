extends CharacterBody2D

const SPEED = 150.0

var click_circle = 0
const CIRLCE_SIZE = 16

@onready var animation_state : AnimationNodeStateMachinePlayback = $AnimationTree.get("parameters/playback")

func _draw():
	draw_set_transform(Vector2(0, 0), 0, Vector2(1, .5))
	draw_arc(Vector2(0, 60), CIRLCE_SIZE, 0, 360, 100, Color(.1, .7, .1))

	if click_circle > 0:
		draw_set_transform(Vector2(0, 0), 0, Vector2(1, .5))
		draw_arc(to_local($NavigationAgent2D.get_final_position()), click_circle, 0, 360, 100, Color(.1, .7, .1))

func _ready():
	animation_state.travel("Idle")
	$NavigationAgent2D.velocity_computed.connect(_on_nav_velocity_computed)
	
func _on_nav_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _physics_process(delta) -> void:
	click_circle -= 66 * delta
	if click_circle > -1:
		queue_redraw()

	_update_state()

	$AnimationTree.set("parameters/Walk/blend_position", velocity.normalized())
	$AnimationTree.set("parameters/Attack/ATTACK_SWING_1H 2/blend_position", velocity.normalized())
	if velocity != Vector2(0, 0):
		$AnimationTree.set("parameters/Idle/blend_position", velocity.normalized())
	
	if not $NavigationAgent2D.is_navigation_finished():
		$NavigationAgent2D.set_velocity(to_local($NavigationAgent2D.get_next_path_position()).normalized() * SPEED)
		move_and_slide()
	else:
		velocity = Vector2(0, 0)

func _update_state() -> void:
	if Input.is_action_just_pressed("attack"):
		animation_state.travel("Attack")
	elif Input.is_action_just_pressed("move"):
		$NavigationAgent2D.target_position = get_global_mouse_position()
		animation_state.travel("Walk")
	elif velocity.length() == 0 && animation_state.get_current_node() != "Idle": 
		animation_state.travel("Idle")
