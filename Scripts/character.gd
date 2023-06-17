extends CharacterBody2D

class_name Character

@export var health = 100 :
	set(value):
		health = value
		$HealthBar.value = health
		if health <= 0:
			animation_state.travel("Death")
			fight_timer.stop()
			target = null
			remove_child($SelectionArea)
			remove_child($CollisionShape2D)
			remove_child($NavigationAgent2D)
			remove_child($HealthBar)
			circle_color = Color(0, 0, 0, 0)
			
			
@export var damage = 10

const CIRLCE_SIZE = 22
var circle_color := Color(.1, .7, .1) :
	set(value):
		circle_color = value
		queue_redraw()

@onready var animation_state : AnimationNodeStateMachinePlayback = $Sprites/AnimationTree.get("parameters/playback")
var target_animation_state = "Idle"

@export  var body : Texture2D
@export var weapon : Texture2D
@export var shield : Texture2D
const SPEED = 150.0

var target : Character = null
var fight_timer : Timer = Timer.new()

func _draw():
	draw_set_transform(Vector2(0, 0), 0, Vector2(1, .5))
	draw_arc(Vector2(0, 0), CIRLCE_SIZE, 0, 360, 100, circle_color)

func _ready():
	$Sprites/AnimationTree.active = true
	animation_state.travel("Idle")
	$NavigationAgent2D.velocity_computed.connect(_on_nav_velocity_computed)
	$Sprites/Body.texture = body
	$Sprites/Weapon.texture = weapon
	$Sprites/Shield.texture = shield
	
	fight_timer.wait_time = 3
	fight_timer.one_shot = false
	fight_timer.timeout.connect(_fight)
	add_child(fight_timer)
	
func _on_nav_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _physics_process(delta) -> void:
	_turn()
	
	if animation_state.get_current_node() == "Walk":
		_process_movement()
		
	_update_state()

func _is_in_range() -> bool:
	return target != null and $AttackRange.overlaps_area(target.get_node("CollisionArea"))

func _process_movement() -> void:
	if target != null:
		$NavigationAgent2D.target_position = target.position

	if not $NavigationAgent2D.is_navigation_finished() and not _is_in_range():
		$NavigationAgent2D.set_velocity(to_local($NavigationAgent2D.get_next_path_position()).normalized() * SPEED)
		move_and_slide()
	else:
		_turn()
		velocity = Vector2(0, 0)
		animation_state.travel(target_animation_state)

func _turn():
	var target_angle
	if velocity != Vector2(0, 0):
		target_angle = velocity.normalized()
		$Sprites/AnimationTree.set("parameters/Walk/blend_position", target_angle)
	if target != null:
		target_angle = (target.position - position).normalized()
		
	if target_angle != null:
		$Sprites/AnimationTree.set("parameters/Idle/blend_position", target_angle)
		$Sprites/AnimationTree.set("parameters/Death/blend_position", target_angle)
		$Sprites/AnimationTree.set("parameters/Attack/Rotate/blend_position", target_angle.x)
		$Sprites/AnimationTree.set("parameters/Interact/Rotate/blend_position", target_angle.x)

func _update_state():
	push_error("_update_state not implemented!")
	
func _wander():
	$NavigationAgent2D.target_position = position + Vector2(randf_range(-100,100), randf_range(-100,100))	
	animation_state.travel("Walk")
	target_animation_state = "Idle"

func _fight():
	animation_state.travel("Walk")
	target_animation_state = "Attack"
	
func _attack_animation_complete():
	if target == null:
		return
		
	target.health = target.health - damage
	
	if target.health <= 0:
		target = null

