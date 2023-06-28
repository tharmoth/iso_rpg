class_name BCharacter extends CharacterBody2D

#var start_point = position
var start_point = Vector2(-500, -300)
var target = null
var SPEED = 150.0
@onready var animation_state : AnimationNodeStateMachinePlayback = $Sprites/AnimationTree.get("parameters/playback")
var animation_rotation := Vector2.ZERO
@onready var navigation_agent = $NavigationAgent2D

var cooldown := Timer.new()

const MAX_HEALTH = 10.0
@export var health := MAX_HEALTH :
	set(value):
		health = min(MAX_HEALTH, value)
		if health <= 0:
			on_death()
		else:
			$HealthBar.value = health

var damage = "1"
var protection := 0.0
var block_chance := 0.0
	
var attacking = false
var current_animation = null

@onready var body = $Sprites/Base

func _ready():
	cooldown.wait_time = 3
	cooldown.one_shot = true
	add_child(cooldown)
	
	$SelectionArea.mouse_entered.connect(_on_mouse_over_mouse_entered)
	$SelectionArea.mouse_exited.connect(_on_mouse_over_mouse_exited)

func get_target_position():
	if target == null:
		return null
	elif target is Vector2:
		return target
	return null

func _physics_process(delta) -> void:
	if health <= 0:
		return
	
	if get_target_position() != null:
		navigation_agent.target_position = get_target_position()
	else:
		navigation_agent.target_position = position

	if animation_state.get_current_node() != current_animation:
		on_animation_state_change()

	_set_animation()
	_turn()

func _set_animation():
	if attacking:
		animation_state.travel("Attack")
	elif not navigation_agent.is_navigation_finished():
		velocity = to_local(navigation_agent.get_next_path_position()).normalized() * SPEED
		move_and_slide()
		animation_state.travel("Walk")
	else:
		animation_state.travel("Idle")

func _turn():
	var new_rotation = null
	
	if animation_state.get_current_node() == "Walk" and velocity != Vector2.ZERO:
		new_rotation = velocity.normalized()
	elif get_target_position() != null:
		new_rotation = (get_target_position() - position).normalized()

	if new_rotation != null:
		animation_rotation = UTILS.clamp_rotation(animation_rotation, new_rotation, 15)
		$Sprites/AnimationTree.set("parameters/Walk/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Idle/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Death/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Attack/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Interact/blend_position", animation_rotation)

func on_animation_state_change():
	if current_animation == "Attack":
		attacking = false
	current_animation = animation_state.get_current_node()
	
func on_death():
	animation_state.travel("Death")
	target = null
#	remove_child($SelectionArea)
	remove_child($CollisionShape2D)
	remove_child($NavigationAgent2D)
	remove_child($HealthBar)
#	circle_color = Color(0, 0, 0, 0)
	
func _on_mouse_over_mouse_entered():
	GlobalCursor.mouse_enter(self)

func _on_mouse_over_mouse_exited():
	GlobalCursor.mouse_exit(self)
	
func set_selected(select : bool):
	if select:
		body.set_material(load("res://shaders/outline_material.tres"))
	else:
		body.set_material(null)

func attack() -> bool:
	if not cooldown.is_stopped():
		return false
	if target == null:
		return false
		
	attacking = true

	var rand = RandomNumberGenerator.new()	
	var attack_roll = rand.randi_range(1, 20)
	var target_ac = target.protection + target.block_chance
	var damage_out = Items.calculate_damage(damage)

	if attack_roll > target_ac:
		print(name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to hit " + target.name + " dealing " + str(damage_out) + " damage!")
		target.health = target.health - damage_out
	else:
		print(name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to miss " + target.name + "!")

	cooldown.start()
	return true
