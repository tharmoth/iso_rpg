class_name BCharacter extends CharacterBody2D

#NPC Vars
var xp_value = 2000
@onready var start_point = position
@export var display_name = "Unknown"

#############
# Initalize #
#############
func _ready():
	_init_actions()
	_init_animation()
	_init_fx()
	_init_equipment()


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


func get_target_position():
	if target is Vector2:
		return target
	return null


func _physics_process_navigation(delta):
	navigate_to_target()


func navigate_to_target():
	if get_target_position() != null:
		interaction.emit(INTERACTION.WALK)
		navigation_agent.target_position = get_target_position()
		velocity = to_local(navigation_agent.get_next_path_position()).normalized() * SPEED
		move_and_slide()
		if navigation_agent.is_navigation_finished():
			target = null
			interaction.emit(INTERACTION.IDLE)
	else:
		navigation_agent.target_position = position


####################################
#           Game Logic             #
####################################
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
		if attack_roll == UTILS.INFINITY:
			GlobalPersistant.post(display_name + " rolled a natural 20 to hit " + target.display_name + " dealing " + str(damage_out) + " damage!")
		else:
			GlobalPersistant.post(display_name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to hit " + target.display_name + " dealing " + str(damage_out) + " damage!")
		target.damage(damage_out)
		if not target.alive:
			target_slain(target)

		interaction.emit(INTERACTION.ATTACK)
	else:
		GlobalPersistant.post(display_name + " rolled " + str(attack_roll) + " against AC " + str(target_ac) + " to miss " + target.display_name + "!")
		interaction.emit(INTERACTION.MISS)

	cooldown.start()
	return true


func interact() -> bool:
	if not cooldown.is_stopped():
		return false
	if target == null:
		return false
	
	interaction.emit(INTERACTION.INTERACT)

	cooldown.start()
	return true


func _on_interact_complete() -> void:
	if target is Interactable:
		var item = target.loot(self)
		if item != null and rpg_character.add_item_to_inventory(item):
			GlobalPersistant.post(ItemDatabase.get_item(item).name + " added to inventory!")
	if target is BCharacter:
		var items = target.loot(self)
		for item in items:
			if rpg_character.add_item_to_inventory(item):
				GlobalPersistant.post(ItemDatabase.get_item(item).name + " added to inventory!")


func on_death():
	alive = false
	target = null
	
	remove_child($CollisionShape2D)
	remove_child($NavigationAgent2D)
	$HealthBar.visible = false
	
	interaction.emit(INTERACTION.DEATH)
	queue_redraw()


func _update_health(old_health, new_health):
	if new_health <  old_health and old_health > 0:
		interaction.emit(INTERACTION.HIT)
	if new_health <= 0:
		on_death()


func damage(value):
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


###################################
# Animation variables and methods #
###################################
@onready var animation_state : AnimationNodeStateMachinePlayback = $Sprites/AnimationTree.get("parameters/playback")
var animation_current = null
var animation_rotation := Vector2.ZERO :
	set(value):
		animation_rotation = value	
		$Sprites/AnimationTree.set("parameters/Walk/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Idle/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Death/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Attack/blend_position", animation_rotation)
		$Sprites/AnimationTree.set("parameters/Interact/blend_position", animation_rotation)
		
var animation_to_play := ""
var animation_offset = Vector2.ZERO
var animaiton_offset_target = Vector2.ZERO
var animation_offset_tween
var animation_advance_time = 0

func _init_animation():
	interaction.connect(func(action):
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
				animation_to_play = "Walk"
			INTERACTION.IDLE:
				animation_to_play = "Idle"
			_:
				pass
	)
	interaction.emit(INTERACTION.IDLE)
	
#	navigation_agent.velocity_computed.connect(func(computed_velocity): velocity = computed_velocity)



func _physics_process_animation(delta):
	var test = $Sprites/AnimationTree.get("parameters/StateMachine/playback")
	if animation_state.get_current_node() != animation_current:
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
		print("playing animation " + animation_to_play)
		
		
		animation_advance_time = RandomNumberGenerator.new().randf_range(0, 100)
		var animation_speed = RandomNumberGenerator.new().randf_range(.95, 1.05)
		print("advancing!" + str(animation_advance_time) + ", speed: " + str(animation_speed))
#		$Sprites/AnimationTree.advance(animation_advance_time)
#		$Sprites/AnimationTree.set("parameters/BlendTree/TimeScale/scale", animation_speed)
#		$Sprites/AnimationTree.active = false
		animation_state.travel(animation_to_play)

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
	set_highlighted(false)
	animation_state.start("Death")
	if rpg_character.health == UTILS.MINUS_INFINITY:
		$Sprites/AnimationTree.advance(100)


############################
# FX Variables and Methods #
############################
@onready var blood_offset = $Blood.position

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


func _physics_process_fx(delta):
	if $Blood.position != animaiton_offset_target + blood_offset:
		$Blood.position = animation_offset + blood_offset


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


func on_hit_fx():
	if rpg_character.health > UTILS.MINUS_INFINITY and alive:
		$Voice/HitPlayer.play()
		$Blood.emitting = true


func on_death_fx():
	if rpg_character.health > UTILS.MINUS_INFINITY:
		$Voice/DeathPlayer.play()
		$Blood.emitting = true


################################
# Sprite Variables and Methods #
################################
var weapon = "unarmed" :
	set(value):
		if value == null:
			return
			
		weapon = value
		
		var texture = null
		var texture_path = "res://Assets/characters/male/Weapons/" + weapon + ".png"
		if value != null and ResourceLoader.exists(texture_path):
			texture = load(texture_path)
		$Sprites/Weapon.texture = texture
var armor = "clothing" :
	set(value):
		if value == null:
			return
		armor = value
		
		var top_texture = null
		var bottom_texture = null
		var top_texture_path = "res://Assets/characters/male/Top/" + armor + ".png"
		var bottom_texture_path = "res://Assets/characters/male/Bottom/" + armor + ".png"
		if value != null and ResourceLoader.exists(top_texture_path) and ResourceLoader.exists(bottom_texture_path):
			top_texture = load(top_texture_path)
			bottom_texture = load(bottom_texture_path)
		$Sprites/Top.texture = top_texture
		$Sprites/Bottom.texture = bottom_texture
var shield = "unarmed_oh" :
	set(value):
		if value == null:
			return
		shield = value
		
		var texture = null
		var texture_path = "res://Assets/characters/male/Weapons/" + shield + ".png"
		if value != null and ResourceLoader.exists(texture_path):
			texture = load(texture_path)
		$Sprites/Shield.texture = texture


func _init_equipment():
	weapon = rpg_character.weapon
	armor = rpg_character.armor
	shield = rpg_character.shield


func _update_sprites(slot, value):
	if get(slot) != null:
		set(slot, value)


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
	}
