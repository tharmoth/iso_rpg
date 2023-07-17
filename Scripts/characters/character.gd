class_name BCharacter extends CharacterBody2D

#NPC Vars
var xp_value = 2000
@onready var start_point = position
@export var display_name = UTILS.MALE_NAMES[RandomNumberGenerator.new().randi_range(0, UTILS.MALE_NAMES.size() - 1)]
var state : INTERACTION = INTERACTION.IDLE

#############
# Initalize #
#############
func _ready():
	_init_navigation()
	_init_actions()
	_init_animation()
	_init_fx()
	_init_equipment()
	# TODO: make sure interations are only called when needed
#	interaction.connect(func(shon): print(INTERACTION.keys()[shon]))
	interaction.connect(func(shon): state = shon)
	$Sprites/AnimationTree.active = true


func _physics_process(delta) -> void:
	if not alive or get_parent() == null:
		return
	_physics_process_animation(delta)
	_physics_process_navigation(delta)
	_physics_process_fx(delta)
	queue_redraw()


####################################
# Navigation variables and methods #
####################################
@onready var navigation_agent = $NavigationAgent2D
var SPEED = 150.0
var target = null
var walk_timer = Timer.new()

func _init_navigation():
	walk_timer.one_shot = true
	
	print(walk_timer.wait_time)
	walk_timer.timeout.connect(func(): interaction.emit(INTERACTION.WALK))
	add_child(walk_timer)

func get_target_position():
	if target is Vector2:
		return target
	return null


func _physics_process_navigation(delta):
	navigate_to_target()


func navigate_to_target():
	if get_target_position() != null and get_target_position().distance_to(position) > 5:
		navigation_agent.target_position = get_target_position()
		if animation_state.get_current_node() != "Walk" and walk_timer.is_stopped():
#			interaction.emit(INTERACTION.WALK)
			walk_timer.wait_time = RandomNumberGenerator.new().randf_range(0, .1)
			walk_timer.start()
			
		if animation_state.get_current_node() == "Walk" and walk_timer.is_stopped():
			velocity = to_local(navigation_agent.get_next_path_position()).normalized() * SPEED
			move_and_slide()	
	else:
		navigation_agent.target_position = position
		velocity = Vector2.ZERO
	
	if navigation_agent.is_navigation_finished() and (state == INTERACTION.WALK or animation_state.get_current_node() == "Walk"):
		target = null
		interaction.emit(INTERACTION.IDLE)
		


####################################
#           Game Logic             #
####################################
var interact_timer = Timer.new()
var cooldown := Timer.new()
var alive = true
var rpg_character = RPGCharacter.new() : 
	set(value):
		if value is Dictionary:
			for i in value.keys():
				rpg_character.set(i, jsonify.godotify(value[i]))
		elif value is RPGCharacter:
			rpg_character = value
		else:
			push_error("Tried to assign a non-RPGCharacter value to rpg_character!")
			

enum INTERACTION {MISS, ATTACK, INTERACT, DEATH, HIT, WALK, IDLE}
signal interaction(result : INTERACTION)

func _init_actions():
	cooldown.wait_time = 3
	cooldown.one_shot = true
	add_child(cooldown)
	
	interact_timer.wait_time = 1
	interact_timer.one_shot = true
	interact_timer.timeout.connect(_on_interact_complete)
	add_child(interact_timer)
	
	rpg_character.health_changed.connect(_update_health)
	rpg_character.equipment_changed.connect(_update_sprites)
	add_child(rpg_character)

func attack() -> bool:
	if not cooldown.is_stopped():
		return false
	if target == null:
		return false

	var attack_roll = rpg_character.attack()
	var target_ac = target.get_ac()
	var damage_out = rpg_character.damage()

	if attack_roll > target_ac or attack_roll == 20:
		interaction.emit(INTERACTION.ATTACK)
		
		if attack_roll == UTILS.INFINITY:
			GUI.post(display_name + " rolled a natural 20 to hit " + target.display_name + " dealing " + str(damage_out) + " damage!")
		else:
			GUI.post(display_name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to hit " + target.display_name + " dealing " + str(damage_out) + " damage!")
		target.damage(damage_out)
		if not target.alive:
			target_slain(target)
	else:
		GUI.post(display_name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to miss " + target.display_name + "!")
		interaction.emit(INTERACTION.MISS)

	cooldown.start()
	return true


func interact() -> bool:
	if not interact_timer.is_stopped():
		return false
	if target == null:
		return false
	
	interaction.emit(INTERACTION.INTERACT)
	interact_timer.start()

#	cooldown.start()
	return true


func _on_interact_complete() -> void:
	if target is Interactable:
		var item = target.loot(self)
		if item != null and item != "":
			add_item(item)
	if target is BCharacter:
		var items = target.loot(self)
		for item in items:
			add_item(item)

func add_item(item):
	if item is int:
		rpg_character.gold += item
		GUI.post(str(item) + " gold gained!")
	elif rpg_character.add_item_to_inventory(item):
		GUI.post(ItemDatabase.get_item(item).name + " added to inventory!")

func on_death():
	alive = false
	target = null
	
	if has_node("CollisionShape2D"):
		remove_child($CollisionShape2D)
	if has_node("NavigationAgent2D"):
		remove_child($NavigationAgent2D)
	
	$HealthBar.visible = false
	
	interaction.emit(INTERACTION.DEATH)
	queue_redraw()


func _update_health(old_health, new_health):
	if new_health <= 0:
		on_death()


func damage(value):
	interaction.emit(INTERACTION.HIT)
	rpg_character.health -= value


func equip(item_slot : String, item_name : String) -> void:
	rpg_character.equip(item_slot, item_name)


func get_ac() -> int:
	return rpg_character.ac()	


func target_slain(dead_character : BCharacter) -> void:
	pass


func loot(player : BCharacter) -> Array:
	var valuables = rpg_character.get_all_items()
	rpg_character.strip()
	return valuables


func rest():
	rpg_character.heal_to_full()
	if rpg_character.can_level_up():
		rpg_character.level_up()


func add_xp(xp : int):
	rpg_character.xp += xp


###################################
# Animation variables and methods #
###################################
@onready var animation_state : AnimationNodeStateMachinePlayback = $Sprites/AnimationTree.get("parameters/StateMachine/playback")
var animation_current = null
var animation_rotation := Vector2.ZERO :
	set(value):
		animation_rotation = value	
		$Sprites/AnimationTree.set("parameters/StateMachine/Walk/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/StateMachine/Idle/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/StateMachine/Death/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/StateMachine/Attack/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/StateMachine/Interact/blend_position", animation_rotation)
		
var animation_to_play := ""
var animation_offset = Vector2.ZERO
var animaiton_offset_target = Vector2.ZERO
var animation_offset_tween
var animaiton_seek = -1
var turn_speed = 15

func _init_animation():
	interaction.connect(_animation_listener)
	interaction.emit(INTERACTION.IDLE)

func _animation_listener(action):
	match action:
		INTERACTION.DEATH:
			on_death_animation()
		INTERACTION.ATTACK:
			animation_to_play = "Attack"
		INTERACTION.MISS:
			animation_to_play = "Attack"
		INTERACTION.INTERACT:
			animation_to_play = "Interact"
		INTERACTION.WALK:
			if animation_to_play == "" or animation_to_play == "Idle":
				animation_to_play = "Walk"
				animaiton_seek = RandomNumberGenerator.new().randf_range(0, 1)
		INTERACTION.IDLE:
			if animation_to_play == "" or animation_to_play == "Walk":
				animation_to_play = "Idle"
				animaiton_seek = RandomNumberGenerator.new().randf_range(0, 1)
		_:
			pass
	_set_animation()


func _physics_process_animation(delta):
	if animation_state.get_current_node() != animation_current:
		on_animation_state_change(animation_state.get_current_node())

	_turn(delta)
	queue_redraw()


func _turn(delta):
	var target_rotation = null
	
	if animation_state.get_current_node() == "Walk" and velocity != Vector2.ZERO:
		target_rotation = velocity.normalized()
	elif get_target_position() != null:
		target_rotation = (get_target_position() - position).normalized()
	elif target != null:
		target_rotation = (target.position - position).normalized()

	if target_rotation != null:
#		var clamped_target_rotation = UTILS.clamp_rotation(animation_rotation, target_rotation, 15)
		animation_rotation += target_rotation * turn_speed * delta
		animation_rotation = animation_rotation.normalized()
		
	var new_animaiton_offset_target = animation_rotation.normalized() * -15 if velocity == Vector2.ZERO else Vector2.ZERO
	if animaiton_offset_target != new_animaiton_offset_target:
		animaiton_offset_target = new_animaiton_offset_target
		if animation_offset_tween:
			animation_offset_tween.kill() # Abort the previous animation.
		animation_offset_tween = create_tween()
		if animation_offset_tween:
			animation_offset_tween.set_trans(Tween.TRANS_QUART)
			animation_offset_tween.tween_property(self, "animation_offset", animaiton_offset_target, .15)


func _set_animation():
	if animation_to_play != "" and animation_state.get_current_node() != animation_to_play:
		animation_state.start(animation_to_play)
		$Sprites/AnimationTree.advance.call_deferred(animaiton_seek)

func on_animation_state_change(new_animtion : String):
	if animation_current == animation_to_play:
		animation_to_play = ""
	animation_current = new_animtion


func set_highlighted(select : bool):
	if not alive and rpg_character.get_all_items().is_empty():
		$SelectionArea.set_highlighted(false)
	else:
		$SelectionArea.set_highlighted(select)


func on_death_animation():
	animation_to_play = "Death"
	set_highlighted(false)
	if rpg_character.health == UTILS.MINUS_INFINITY:
#		$Sprites/AnimationTree.advance(100)
		animaiton_seek = 100
	interaction.disconnect(_animation_listener)


############################
# FX Variables and Methods #
############################
@onready var blood_offset = $Blood.position
var ruffle_timer = Timer.new()

func _init_fx():
	interaction.connect(func(action):
		match action:
			INTERACTION.WALK:
				on_walk_fx()
			INTERACTION.IDLE:
				on_idle_fx()
			INTERACTION.ATTACK:
				on_attack_fx()
			INTERACTION.MISS:
				on_miss_fx()
			INTERACTION.INTERACT:
				on_interact_fx()
			INTERACTION.DEATH:
				on_death_fx()
			INTERACTION.HIT:
				on_hit_fx()
			_:
				pass
	)
	ruffle_timer.one_shot = false
	ruffle_timer.timeout.connect(on_ruffle_fx)
	ruffle_timer.wait_time = RandomNumberGenerator.new().randi_range(60, 600)
	add_child(ruffle_timer)
	ruffle_timer.start()
	
func _physics_process_fx(delta):
	if $Blood.position != animaiton_offset_target + blood_offset:
		$Blood.position = animation_offset + blood_offset
	if animation_state.get_current_node() == "Walk":
		on_walk_fx()

func on_walk_fx():
	if not $Sounds/FootstepPlayer.playing:
		$Sounds/FootstepPlayer.play()


func on_idle_fx():
	$Sounds/FootstepPlayer.stop()


func on_attack_fx():
	$Sounds/SwordStrikePlayer.play()


func on_miss_fx():
	$Sounds/SwingPlayer.play()


func on_interact_fx():
	$Sounds/InteractPlayer.play()
	
	
func on_level_fx():
	$Sounds/LevelUpPlayer.play()


func on_hit_fx():
	if rpg_character.health > UTILS.MINUS_INFINITY and alive and has_node("Voice"):
		get_node("Voice/HitPlayer").play()
		$Blood.emitting = true


func on_death_fx():
	if rpg_character.health > UTILS.MINUS_INFINITY and has_node("Voice"):
		get_node("Voice/DeathPlayer").play()
		$Blood.emitting = true

func on_ruffle_fx():
	if alive and has_node("Voice"):
		get_node("Voice/RufflePlayer").play()

func confirmation_fx():
	if Party.party_leader == self and not GUI.get_node("%Inventory").visible and has_node("Voice"):
		get_node("Voice/ConfirmationPlayer").play()


################################
# Sprite Variables and Methods #
################################
var multisprite : Dictionary = {}

func _init_equipment():
	$Sprites.weapon = rpg_character.weapon
	$Sprites.armor = rpg_character.armor
	$Sprites.shield = rpg_character.shield

func _update_sprites(slot, value):
	if $Sprites.get(slot) != null:
		$Sprites.set(slot, value)
		
func get_icon() -> Texture2D:
	return $Sprites.get_icon()

###################################
# Drawing Variables and Functions #
###################################
var CIRLCE_SIZE = 30
@onready var circle_color = $SelectionArea.circle_color

func _draw():
	if alive:
		draw_set_transform(Vector2(0, 0), 0, Vector2(1, .5))
		draw_arc(animation_offset, CIRLCE_SIZE, 0, 360, 100, circle_color)
		draw_set_transform(Vector2(0, 0), 0, Vector2(1, 1))
		$SelectionArea.position = animation_offset
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
		"display_name" : display_name,
 		
		# Stats
		"position" : jsonify.jsonify(position),
		"start_point" : jsonify.jsonify(start_point),
		
		# Equipment
		"rpg_character" : rpg_character.save(),
		"multisprite" : $Sprites.save()
	}
