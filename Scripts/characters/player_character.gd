class_name Player extends BCharacter

var parent = null
var target_interactable = null
var target_hostile = null

var party_offset : Vector2 :
	get:
		if Party.get_selected_players().size() > 1:
			return get_x_offset(Party.get_selected_players().find(self))

		return Vector2.ZERO

var should_speak_on_movement = true
var waypoint
var level_message_shown = false

signal selection_changed()
var selected = true :
	set(value):
		should_speak_on_movement = true
		if selected != value:
			selected = value
			selection_changed.emit()

var spacing = 60
func get_rectangle_offset(index : int):
	match index:
		0:
			return Vector2(0, -spacing / 2)
		1:
			return Vector2(0, spacing / 2)
		2:
			return Vector2(spacing * 1.25, spacing / 2)
		3:
			return Vector2(spacing * 1.25, -spacing / 2)
		4:
			return Vector2(2 * spacing * 1.25, spacing / 2)
		5:
			return Vector2(2 * spacing * 1.25, -spacing / 2)
	return Vector2.ZERO

func get_x_offset(index : int):
	match index:
		0:
			return Vector2(-spacing * 1.25 / 2, -spacing / 2)
		1:
			return Vector2(spacing * 1.25 / 2, spacing / 2)
	return Vector2.ZERO

func _init():
	super()
	rpg_character.equip("armor", "full_plate")
	rpg_character.equip("weapon", "longsword")
	rpg_character.strength = 18
	rpg_character.constitution = 18

func _ready():
	super()
	SPEED = 300
	cooldown.wait_time = 2.9
	rpg_character.leveled_up.connect(on_level_fx)
	rpg_character.leveled_up.connect(func(): level_message_shown = false)
	rpg_character.xp_gained.connect(func(): 
		if rpg_character.can_level_up() and not level_message_shown:
			level_message_shown = true
			on_level_fx()
			GUI.post(display_name + " can level up!")
			)

	print("Player added to scene!")
	
	rpg_character.equipment_changed.connect(add_gold_to_party)
	
	
func _enter_tree():
	waypoint = preload("res://Scenes/world/waypoint.tscn").instantiate()
	waypoint.get_child(0).play("point_the_way")
	add_sibling(waypoint)

func _exit_tree():
	target_hostile = null

func add_gold_to_party(slot, item):
	if slot == "gold" and item > 0:
		rpg_character.gold -= item
		Party.gold += item

func _physics_process(delta):
	super(delta)
	if not alive:
		return
	_set_target()
	

func _unhandled_input(_event):
	if $SelectionArea.highlighted and Input.is_action_just_released("interact"):
		print("player clicked!")
		for player in Party.players:
			player.selected = false
		selected = true
#		return
	if not selected:
		return
		
#	if not interact_timer.is_stopped():
#		return

	if Input.is_action_pressed("move"):
		if should_speak_on_movement:
			confirmation_fx()
			should_speak_on_movement = false
		
		target_interactable = null
		target_hostile = null
		target = null
		if GlobalCursor.current_state == GlobalCursor.State.MOVE:
			var rotation = Party.players[0].position.angle_to_point(get_global_mouse_position())
			var distance_from_90 = (90 - abs(abs(rad_to_deg(rotation)) - 90)) / 90
#			var offset_rotated = party_offset.rotated(rotation).normalized() * (60 / 2 + 60 / 2  * distance_from_90)
#			var offset_rotated = party_offset.rotated(rotation).normalized()
#			offset_rotated.x = offset_rotated.x * (spacing / 2 + spacing / 2  * distance_from_90)
#			offset_rotated.y = offset_rotated.y * (spacing / 2 + spacing / 2  * distance_from_90)
#			var offset_rotated = Vector2.ZERO
#			offset_rotated.x = party_offset.rotated(rotation).normalized().x * party_offset.x / 2 + (party_offset.x / 2) * distance_from_90
#			offset_rotated.y = party_offset.rotated(rotation).normalized().y * party_offset.y / 2 + (party_offset.y / 2) * distance_from_90
			var offset_rotated = party_offset

			target = get_global_mouse_position() + offset_rotated
			waypoint.position = target
			waypoint.visible = true
		elif GlobalCursor.current_state == GlobalCursor.State.ATTACK:
			target_hostile = GlobalCursor.highlighted
			target = target_hostile.position
		elif GlobalCursor.current_state == GlobalCursor.State.CAN_INTERACT and Party.party_leader == self:
			target_interactable = GlobalCursor.highlighted
			target = target_interactable.position
			
	else:
		if Input.is_action_pressed("move") and GlobalCursor.current_state == GlobalCursor.State.MOVE and target != null:
			target = get_global_mouse_position()
			target_interactable = null

func _set_target() -> void:
	autotarget_nearby_hostiles()
	attack_target_hostile()
	loot_target_interactable()
	if navigation_agent.is_navigation_finished():
		waypoint.visible = false

func autotarget_nearby_hostiles():
	if target_hostile == null and target_interactable == null and target == null:
		for enemy in get_tree().get_nodes_in_group("Hostile"):
			if enemy.alive and position.distance_to(enemy.position) < 200:
				target_hostile = enemy
				return

func attack_target_hostile():
	if target_hostile != null and not target_hostile.alive:
		target_hostile = null
	
	if target_hostile is BCharacter and position.distance_to(target_hostile.position) < 50:
		target = target_hostile
		attack()
		
func loot_target_interactable():
	if (target_interactable is Interactable or target_interactable is BCharacter) and position.distance_to(target_interactable.position) < 50:
		target = target_interactable
		interact()

func _on_interact_complete():
	super()
	target_interactable = null

func _start_screen():
	Party.change_scene("res://Scenes/ui/start_screen.tscn")


func on_death():
	super()
#	Party.players.erase(self)
	
	for player in Party.players:
		if player.alive:
			return
		
	GUI.get_node("%DeathLabel").visible = true
	var timer = Timer.new()
	timer.wait_time = 5
	timer.one_shot = true
	timer.timeout.connect(_start_screen)
	add_child(timer)
	timer.start()


func target_slain(dead_character : BCharacter):
	rpg_character.xp += dead_character.xp_value


var draw_pos = Vector2.ZERO
func _draw():
	super()
	
	
#	if alive and get_target_position() != null:
##		draw_pos = get_target_position()
#		draw_set_transform(Vector2(0, 0), 0, Vector2(1, .5))
#		draw_arc(to_local(get_target_position()), 30, 0, 360, 100, UTILS.PLAYER_COLOR, 1, true)
#		draw_set_transform(Vector2(0, 0), 0, Vector2(1, 1))

########################################
# Save related functions and variables #
########################################
func save():
	return {
		# Metadata
		"filename" : get_scene_file_path(),
		"display_name" : display_name,
		
		# Stats
		"position" : jsonify.jsonify(position),
		"start_point" : jsonify.jsonify(start_point),
		"animation_rotation" : jsonify.jsonify(animation_rotation),
		
		# Equipment
		"rpg_character" : rpg_character.save(),
		"multisprite" : $Sprites.save(),
	}
