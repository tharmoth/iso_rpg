class_name Character extends CharacterBody2D

var SPEED = 200.0

const CIRLCE_SIZE = 22

const MAX_HEALTH := 10

# you can't override setters so we use a signal
signal health_changed
@export var health := MAX_HEALTH :
	set(value):
		health = min(MAX_HEALTH, value)
		health_changed.emit()
		if health <= 0:
			on_death()
		else:
			$HealthBar.value = health

var weapon = Items.ITEM_NAME.unarmed :
	set(value):
		if value is Items.ITEM_NAME:
			value = Items.items.get(value)
		weapon = value
		
		if value != null and value.texture != null:
			$Sprites/Weapon.texture = load(weapon.texture)
		else:
			$Sprites/Weapon.texture = null
var armor = Items.ITEM_NAME.clothing :
	set(value):
		if value is Items.ITEM_NAME:
			value = Items.items.get(value)
		armor = value
		if value != null:
			$Sprites/Top.texture = load(armor.top_texture)
			$Sprites/Bottom.texture = load(armor.bottom_texture)
var shield = null :
	set(value):
		if value is Items.ITEM_NAME:
			value = Items.items.get(value)
		shield = value
		if value != null:
			$Sprites/Shield.texture = load(shield.texture)
		
		

var circle_color := UTILS.PLAYER_COLOR :
	set(value):
		circle_color = value
		queue_redraw()

@onready var animation_state : AnimationNodeStateMachinePlayback = $Sprites/AnimationTree.get("parameters/playback")
var target_animation_state := "Idle"
var animation_rotation := Vector2.ZERO

@onready var steering = preload("res://Scripts/context_based_steering.gd").new()
var target = null :
	set(value):
		target = value
		queue_redraw()
var target_interactable : Interactable = null

var action_timer := Timer.new()
var health_regen := Timer.new()

func _ready():
	$Sprites/AnimationTree.active = true
	animation_state.travel("Idle")
	$NavigationAgent2D.velocity_computed.connect(_on_nav_velocity_computed)
	
	steering.init(self)
	
	action_timer.wait_time = 3
	action_timer.one_shot = false
	add_child(action_timer)

	health_regen.wait_time = 1
	health_regen.one_shot = false
	health_regen.timeout.connect(_regen)
	add_child(health_regen)
#	health_regen.start()
	
	$Sprites/AnimationTree.animation_finished.connect(_on_animation_changed)
#	$Sprites/AnimationPlayer.animation_finished.connect(_on_animation_changed)
	
	NavigationServer2D.agent_set_map($NavigationAgent2D.get_rid(), get_world_2d().get_navigation_map())
	NavigationServer2D.agent_set_radius($NavigationAgent2D.get_rid(), 25)
	
	$HealthBar.max_value = MAX_HEALTH
	
func _on_animation_changed(old_name):
	if old_name.contains("ATTACK"):
		_attack_animation_complete()
	elif old_name.contains("INTERACT"):
		_on_interact_complete()
	elif old_name.contains("DEAD"):
		process_mode = Node.PROCESS_MODE_DISABLED
 
func _regen():
	health += 1	
	
func _on_nav_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity



func _physics_process(delta) -> void:
	if health <= 0:
		return

	_turn()
	
	# Follow the target if not currently attacking
	if not action_timer.is_stopped() and not _is_in_range() and animation_state.get_current_node() != "Attack" and target != null:
		_fight()
		queue_redraw()
	
	if animation_state.get_current_node() == "Walk":
		_process_movement()
		
	_update_state()

func _is_in_range() -> bool:
	return target != null and position.distance_to(target.position) < 28

func _process_movement() -> void:
	if health <= 0:
		return
	
	if target != null:
		$NavigationAgent2D.target_position = target.position

	if not $NavigationAgent2D.is_navigation_finished() and not _is_in_range():
		# $NavigationAgent2D.set_velocity(to_local($NavigationAgent2D.get_next_path_position()).normalized() * SPEED)
		velocity = to_local($NavigationAgent2D.get_next_path_position()).normalized() * SPEED
#		velocity = steering.update()
		
		move_and_slide()
		position = position.snapped(Vector2.ONE)
	else:
		_turn()
		velocity = Vector2(0, 0)
		animation_state.travel(target_animation_state)
		queue_redraw()

func _turn():
	var new_rotation = null
	
	if animation_state.get_current_node() == "Walk" and velocity != Vector2.ZERO:
		new_rotation = velocity.normalized()
	elif target != null:
		new_rotation = (target.position - position).normalized()

	if new_rotation != null:
		animation_rotation = UTILS.clamp_rotation(animation_rotation, new_rotation, 15)
		$Sprites/AnimationTree.set("parameters/Walk/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Idle/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Death/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Attack/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Interact/blend_position", animation_rotation)

func _update_state():
	push_error("_update_state not implemented!")
	
func _loot():
	push_error("_loot not implemented!")
	
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
		
	var rand = RandomNumberGenerator.new()	
	var attack_roll = rand.randi_range(1, 20) + 20
	var target_ac = target.get_ac()
	var damage_out = Items.calculate_damage(weapon.damage)

	if attack_roll > target_ac:
		target.health = target.health - damage_out
		GlobalPersistant.print(name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to hit " + target.name + " dealing " + str(damage_out) + " damage!")
	else:
		GlobalPersistant.print(GlobalPersistant.console.text + name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to miss " + target.name + "!")
	
	if target.health <= 0:
		target = null
		action_timer.stop()
	else:
		action_timer.start()

func _on_interact_complete() -> void:
	var item = target_interactable.loot(self)
	if item != null:
		equip(item) 

func equip(item) -> void:
	if item is Items.ITEM_NAME:
		item = Items.items.get(item)
	
	if item.slot == "weapon":
		weapon = item
	elif item.slot == "body":
		armor = item
	elif item.slot == "shield":
		shield = item

 
func on_death():
	animation_state.travel("Death")
	action_timer.stop()
	health_regen.stop()
	target = null
	remove_child($SelectionArea)
	remove_child($CollisionShape2D)
	remove_child($NavigationAgent2D)
	remove_child($HealthBar)
	circle_color = Color(0, 0, 0, 0)
	
func get_ac() -> int:
	var ac = 0
	if armor != null:
		ac += armor.ac
	else:
		ac = 10
		
	if shield != null:
		ac += shield.ac
		
	return ac

func _draw():
	draw_set_transform(Vector2(0, 0), 0, Vector2(1, .5))
	draw_arc(Vector2(0, 0), CIRLCE_SIZE, 0, 360, 100, circle_color)
	draw_set_transform(Vector2(0, 0), 0, Vector2(1, 1))
  
#	for i in steering.num_rays:
#		var bad_color = Color(1, 0, 0)
#		var good_color = Color(0, 1, 0)
#
#		if steering.danger[i] != null and steering.danger[i] == 0:
#			draw_line(to_local(position), to_local(position + steering.ray_directions[i].rotated(animation_rotation.angle()) * steering.look_ahead), good_color)
#		else: 
#			print(steering.danger[i])
#			draw_line(to_local(position), to_local(position + steering.ray_directions[i].rotated(animation_rotation.angle()) * steering.look_ahead), bad_color)

#	if velocity != Vector2.ZERO:
#		draw_line(Vector2.ZERO, velocity.normalized() * 75, Color(0, 0, 1), 2)
	
	if _is_in_range():
#		draw_line(Vector2(0, 0), to_local(target.position), circle_color)
		
		var target_pos = to_local(target.position)

		var start = Vector2.ZERO + target_pos / 10
		var end = target_pos - target_pos / 10
		var point = Vector2(0, -15)
		
#		if self is Player:
#			start += Vector2(0, 2)
#			end += Vector2(0, 2)
#			point += Vector2(0, 2)
		
		var curve = Curve2D.new()
		curve.add_point(start, point, point)
		curve.add_point(end, point, point)

		var curve_points = curve.tessellate()
		for index in len(curve_points) - 1:
			draw_line(curve_points[index], curve_points[index + 1], circle_color, 2)
