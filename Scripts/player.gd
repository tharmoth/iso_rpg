class_name Player extends BCharacter

var spawn = "default"
var spawn_scene = null :
	set(value):
		spawn_scene = value
		if spawn_scene != null:
			spawn = ""
var parent = null
var target_interactable = null
var party_offset = Vector2.ZERO

signal selection_changed()
var selected = false :
	set(value):
		if selected != value:
			selected = value
			selection_changed.emit()

func _ready():
	super()
	SPEED = 300
	display_name = "CHARNAME"
	cooldown.wait_time = 2.9
	tree_entered.connect(func(): spawn_scene = null)
	rpg_character.leveled_up.connect(_on_level_up)
	if GlobalPersistant.players.find(self) == -1:
		party_offset = Vector2(0, GlobalPersistant.players.size() * 60)
	else:
		party_offset = Vector2(0, GlobalPersistant.players.find(self) * 60)

func _physics_process(delta):
	super(delta)
	if not alive:
		return
	_set_target()
	
	
func _unhandled_input(_event):
	if $SelectionArea.highlighted and Input.is_action_just_released("interact"):
		print("player clicked!")
		for player in GlobalPersistant.players:
			player.selected = false
		selected = true
#		return
	if not selected:
		return

	if Input.is_action_pressed("move"):
		if GlobalCursor.current_state == GlobalCursor.State.MOVE:
			#TODO fix party rotation!
#			var rotation = GlobalPersistant.players[0].position.angle_to_point(get_global_mouse_position())
#			var offset_rotated = party_offset.rotated(rotation)

			target = get_global_mouse_position() + party_offset
			target_interactable = null
		elif GlobalCursor.current_state == GlobalCursor.State.ATTACK:
			target_interactable = GlobalCursor.highlighted
			target = target_interactable.position
		elif GlobalCursor.current_state == GlobalCursor.State.CAN_INTERACT or GlobalCursor.current_state == GlobalCursor.State.INTERACTING and GlobalPersistant.selected_player == self:
			target_interactable = GlobalCursor.highlighted
			target = target_interactable.position
		else:
			target = null
	else:
		if Input.is_action_pressed("move") and GlobalCursor.current_state == GlobalCursor.State.MOVE and target != null:
			target = get_global_mouse_position()
			target_interactable = null

func _set_target() -> void:
	if target_interactable == null:
		return
		
	if position.distance_to(target_interactable.position) > 50:
		return
		
	if target_interactable is BCharacter:
		if target_interactable.alive:
			target = target_interactable
			attack()
		else:
			target = target_interactable
			interact()

	elif target_interactable is Interactable:
		target = target_interactable
		interact()


func on_animation_state_change(new_animtion : String):
	if animation_current == "Interact":
		_on_interact_complete()
		target_interactable = null
	super(new_animtion)


func _start_screen():
	GlobalPersistant.change_scene("res://Scenes/ui/start_screen.tscn")


func on_death():
	super()
	GlobalPersistant.players.erase(self)
	
	for player in GlobalPersistant.players:
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
	if rpg_character.can_level_up():
		rpg_character.level_up()


func _on_level_up(new_level):
	$Sounds/LevelUpPlayer.call_deferred("play")


########################################
# Save related functions and variables #
########################################
func save():
	return {
		# Metadata
		"filename" : get_scene_file_path(),
		"spawn_scene" : spawn_scene if spawn_scene != null else get_tree().current_scene.scene_file_path,
		"display_name" : display_name,
		
		# Stats
		"position" : jsonify.jsonify(position),
		"start_point" : jsonify.jsonify(start_point),
		"animation_rotation" : jsonify.jsonify(animation_rotation),
		
		# Equipment
		"rpg_character" : rpg_character.save(),
	}
