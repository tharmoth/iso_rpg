class_name BCharacter extends CharacterBody2D

@onready var start_point = position
var target = null

@export var display_name = "Unknown"

const MAX_HEALTH = 10
signal health_changed
@export var health := MAX_HEALTH :
	set(value):
		if value < health and value > 0:
			$Voice/HitPlayer.play()
		health = min(MAX_HEALTH, max(0, value))
		health_changed.emit()
		if health <= 0:
			on_death()
		else:
			$HealthBar.value = health


func _ready():
	_init_actions()
	_init_selection()
	_init_equipment()

	$HealthBar.max_value = MAX_HEALTH
	

func _physics_process(delta) -> void:
	if health <= 0:
		return
	_physics_process_animation(delta)
	_physics_process_navigation(delta)
	queue_redraw()
	
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
		if not $Sounds/FootstepPlayer.playing:
			$Sounds/FootstepPlayer.play()
		navigation_agent.target_position = get_target_position()
		if navigation_agent.is_navigation_finished():
			target = null
			$Sounds/FootstepPlayer.stop()
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
		
	animation_to_play = "Attack" # Play the attack animation
	

	var rand = RandomNumberGenerator.new()	
	var attack_roll = rand.randi_range(1, 20)
	var target_ac = target.get_ac()
	var damage_out = Items.roll_dice(weapon.damage)

	if attack_roll > target_ac or attack_roll == 20:
		GlobalPersistant.print(display_name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to hit " + target.display_name + " dealing " + str(damage_out) + " damage!")
		target.health = target.health - damage_out
		$Sounds/SwordStrikePlayer.play()
	else:
		GlobalPersistant.print(display_name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to miss " + target.display_name + "!")
		$Sounds/SwingPlayer.play()

	cooldown.start()
	return true

func interact() -> bool:
	if not cooldown.is_stopped():
		return false
	if target == null:
		return false
	
	$Sounds/InteractPlayer.play()
	animation_to_play = "Interact"
		
	cooldown.start()
	return true
	
func _on_interact_complete() -> void:
	if target is Interactable:
		var item = target.loot(self)
		if item != null:
			equip(item) 


###################################
# Animation variables and methods #
###################################
@onready var animation_state : AnimationNodeStateMachinePlayback = $Sprites/AnimationTree.get("parameters/playback")
var current_animation = null
var animation_rotation := Vector2.ZERO
var animation_to_play := ""

func _physics_process_animation(delta):
	if animation_state.get_current_node() != current_animation:
		on_animation_state_change(animation_state.get_current_node())
	_set_animation()
	_turn()
	
	
func _turn():
	var new_rotation = null
	
	if animation_state.get_current_node() == "Walk" and velocity != Vector2.ZERO:
		new_rotation = velocity.normalized()
	elif get_target_position() != null:
		new_rotation = (get_target_position() - position).normalized()
	elif target != null:
		new_rotation = (target.position - position).normalized()

	if new_rotation != null:
		animation_rotation = UTILS.clamp_rotation(animation_rotation, new_rotation, 15)
		$Sprites/AnimationTree.set("parameters/Walk/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Idle/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Death/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Attack/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Interact/blend_position", animation_rotation)
		


func _set_animation():
	if animation_to_play != "":
		animation_state.travel(animation_to_play)
	elif not navigation_agent.is_navigation_finished():
		velocity = to_local(navigation_agent.get_next_path_position()).normalized() * SPEED
		move_and_slide()
		animation_state.travel("Walk")
	else:
		velocity = Vector2.ZERO
		animation_state.travel("Idle")


func on_animation_state_change(new_animtion : String):
	if current_animation == animation_to_play:
		animation_to_play = ""
	current_animation = new_animtion


func on_death():
	animation_state.travel("Death")
	target = null
#	remove_child($SelectionArea)
	remove_child($CollisionShape2D)
	remove_child($NavigationAgent2D)
	remove_child($HealthBar)
	$Voice/DeathPlayer.play()
	queue_redraw()
#	circle_color = Color(0, 0, 0, 0)


###################################
# Selection variables and methods #
###################################
@onready var body = $Sprites/Base
var selection_color_tween

func _init_selection():
	$SelectionArea.mouse_entered.connect(_on_mouse_over_mouse_entered)
	$SelectionArea.mouse_exited.connect(_on_mouse_over_mouse_exited)

func _on_mouse_over_mouse_entered():
	GlobalCursor.mouse_enter(self)


func _on_mouse_over_mouse_exited():
	GlobalCursor.mouse_exit(self)


func set_selected(select : bool):
	if health <= 0:
		return
	
	var default_color = UTILS.PLAYER_COLOR if self is Player else UTILS.HOSTILE_COLOR
	if select:
		body.set_material(load("res://shaders/outline_material.tres"))
		selection_color_tween = create_tween()
		blink()
	else:
		body.set_material(null)
		selection_color_tween.kill()
		circle_color = default_color

func blink() -> void:
	if selection_color_tween:
		selection_color_tween.kill() # Abort the previous animation.
	selection_color_tween = create_tween()
	var default_color = UTILS.PLAYER_COLOR if self is Player else UTILS.HOSTILE_COLOR
	selection_color_tween.tween_property(self, "circle_color", UTILS.SELECTED_COLOR, .5)
	selection_color_tween.tween_property(self, "circle_color", default_color, .5)
	selection_color_tween.tween_callback(blink)

##################################
# Equpment Variables and Methods #
##################################
@export var weapon = Items.ITEM_NAME.unarmed :
	set(value):
		if value is Items.ITEM_NAME:
			value = Items.items.get(value)
		weapon = value
		
		var texture = null
		if value != null && weapon.texture != null:
			texture = load(weapon.texture)
		$Sprites/Weapon.texture = texture
@export var armor = Items.ITEM_NAME.clothing :
	set(value):
		if value is Items.ITEM_NAME:
			value = Items.items.get(value)
		armor = value
		
		var top_texture = null
		var bottom_texture = null
		if value != null and armor.top_texture != null and armor.bottom_texture != null:
			top_texture = load(armor.top_texture)
			bottom_texture = load(armor.bottom_texture)
		$Sprites/Top.texture = top_texture
		$Sprites/Bottom.texture = bottom_texture
@export var shield = Items.ITEM_NAME.unarmed_oh :
	set(value):
		if value is Items.ITEM_NAME:
			value = Items.items.get(value)
		shield = value
		
		var texture = null
		if value != null and shield.texture != null:
			texture = load(shield.texture)
		$Sprites/Shield.texture = texture

func _init_equipment():
	weapon = weapon
	armor = armor
	shield = shield

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
	elif item.slot == "mouth":
		var healing = min(Items.roll_dice(item.healing), MAX_HEALTH - health)
		GlobalPersistant.print(display_name + " ate food healing " + str(healing) + " hitpoints!")
		health += healing
		
		
func get_ac() -> int:
	var ac = 0
	if armor != null:
		ac += armor.ac
	else:
		ac = 10
		
	if shield != null:
		ac += shield.ac
		
	return ac

###################################
# Drawing Variables and Functions #
###################################
var CIRLCE_SIZE = 30
var circle_color = UTILS.PLAYER_COLOR if self is Player else UTILS.HOSTILE_COLOR
var circle_offset = Vector2.ZERO
var target_offset = Vector2.ZERO
var circle_location_tween

func _draw():
	if health > 0:
		var new_target_offset = animation_rotation.normalized() * -15 if velocity == Vector2.ZERO else Vector2.ZERO
		if target_offset != new_target_offset:
			target_offset = new_target_offset
			if circle_location_tween:
				circle_location_tween.kill() # Abort the previous animation.
			circle_location_tween = create_tween()
			circle_location_tween.set_trans(Tween.TRANS_QUART)
			circle_location_tween.tween_property(self, "circle_offset", target_offset, .15)
		
		draw_set_transform(Vector2(0, 0), 0, Vector2(1, .5))
		draw_arc(circle_offset, CIRLCE_SIZE, 0, 360, 100, circle_color)
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
	
#	if _is_in_range():
##		draw_line(Vector2(0, 0), to_local(target.position), circle_color)
#
#		var target_pos = to_local(target.position)
#
#		var start = Vector2.ZERO + target_pos / 10
#		var end = target_pos - target_pos / 10
#		var point = Vector2(0, -15)
#
##		if self is Player:
##			start += Vector2(0, 2)
##			end += Vector2(0, 2)
##			point += Vector2(0, 2)
#
#		var curve = Curve2D.new()
#		curve.add_point(start, point, point)
#		curve.add_point(end, point, point)
#
#		var curve_points = curve.tessellate()
#		for index in len(curve_points) - 1:
#			draw_line(curve_points[index], curve_points[index + 1], circle_color, 2)


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
		"position" : jsonify.jsonify(position),
		"start_point" : jsonify.jsonify(start_point),
		
		# Equipment
		"weapon" : weapon,
		"armor" : armor,
		"shield" : shield,
	}
