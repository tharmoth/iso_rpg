class_name BCharacter extends CharacterBody2D

var start_point = position
var target = null

const MAX_HEALTH = 10.0
signal health_changed
@export var health := MAX_HEALTH :
	set(value):
		health = min(MAX_HEALTH, value)
		health_changed.emit()
		if health <= 0:
			on_death()
		else:
			$HealthBar.value = health


func _ready():
	_init_actions()
	_init_selection()
	
	$HealthBar.max_value = MAX_HEALTH
	
	equip(Items.ITEM_NAME.hide)
	equip(Items.ITEM_NAME.battle_axe)


func _physics_process(delta) -> void:
	if health <= 0:
		return
	_physics_process_animation(delta)
	_physics_process_navigation(delta)
	
func get_target_position():
	if target is Vector2:
		return target
	return null

####################################
# Navigation variables and methods #
####################################
@onready var navigation_agent = $NavigationAgent2D
var SPEED = 150.0

func _physics_process_navigation(delta):
	navigate_to_target()


func navigate_to_target():
	if get_target_position() != null:
		navigation_agent.target_position = get_target_position()
	else:
		navigation_agent.target_position = position


####################################
# Interaction variables and method #
####################################
var cooldown := Timer.new()

func _init_actions():
	cooldown.wait_time = 3
	cooldown.one_shot = true
	add_child(cooldown)


func attack() -> bool:
	if not cooldown.is_stopped():
		return false
	if target == null:
		return false
		
	attacking = true # Play the attack animation

	var rand = RandomNumberGenerator.new()	
	var attack_roll = rand.randi_range(1, 20)
	var target_ac = target.get_ac()
	var damage_out = Items.calculate_damage(weapon.damage)

	if attack_roll > target_ac:
		GlobalPersistant.print(name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to hit " + target.name + " dealing " + str(damage_out) + " damage!")
		target.health = target.health - damage_out
	else:
		GlobalPersistant.print(name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to miss " + target.name + "!")

	cooldown.start()
	return true


###################################
# Animation variables and methods #
###################################
@onready var animation_state : AnimationNodeStateMachinePlayback = $Sprites/AnimationTree.get("parameters/playback")
var current_animation = null
var animation_rotation := Vector2.ZERO
var attacking = false

func _physics_process_animation(delta):
	if animation_state.get_current_node() != current_animation:
		on_animation_state_change()
	_set_animation()
	_turn()
	
	
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


func _set_animation():
	if attacking:
		animation_state.travel("Attack")
	elif not navigation_agent.is_navigation_finished():
		velocity = to_local(navigation_agent.get_next_path_position()).normalized() * SPEED
		move_and_slide()
		animation_state.travel("Walk")
	else:
		animation_state.travel("Idle")


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


###################################
# Selection variables and methods #
###################################
@onready var body = $Sprites/Base

func _init_selection():
	$SelectionArea.mouse_entered.connect(_on_mouse_over_mouse_entered)
	$SelectionArea.mouse_exited.connect(_on_mouse_over_mouse_exited)

func _on_mouse_over_mouse_entered():
	GlobalCursor.mouse_enter(self)


func _on_mouse_over_mouse_exited():
	GlobalCursor.mouse_exit(self)


func set_selected(select : bool):
	if select:
		body.set_material(load("res://shaders/outline_material.tres"))
	else:
		body.set_material(null)


##################################
# Equpment Variables and Methods #
##################################
var weapon = Items.ITEM_NAME.unarmed :
	set(value):
		if value is Items.ITEM_NAME:
			value = Items.items.get(value)
		weapon = value
		
		if value != null && weapon.texture != null:
			$Sprites/Weapon.texture = load(weapon.texture)
var armor = Items.ITEM_NAME.clothing :
	set(value):
		if value is Items.ITEM_NAME:
			value = Items.items.get(value)
		armor = value
		if value != null and armor.top_texture != null and armor.bottom_texture != null:
			$Sprites/Top.texture = load(armor.top_texture)
			$Sprites/Bottom.texture = load(armor.bottom_texture)
var shield = null :
	set(value):
		if value is Items.ITEM_NAME:
			value = Items.items.get(value)
		shield = value
		if value != null and shield.texture != null:
			$Sprites/Shield.texture = load(shield.texture)


# Routes and Item to the correct slot.
func equip(item) -> void:
	if item is Items.ITEM_NAME:
		item = Items.items.get(item)
	
	if item.slot == "weapon":
		weapon = item
	elif item.slot == "body":
		armor = item
	elif item.slot == "shield":
		shield = item
		
		
func get_ac() -> int:
	var ac = 0
	if armor != null:
		ac += armor.ac
	else:
		ac = 10
		
	if shield != null:
		ac += shield.ac
		
	return ac


########################################
# Save related functions and variables #
########################################
func save():
	return {
		# Metadata
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		
		# Stats
		"health" : health,
		"position_x" : position.x,
		"position_y" : position.y,
		
		# Equipment
		"weapon" : weapon,
		"armor" : armor,
		"shield" : shield,
	}
