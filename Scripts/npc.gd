extends "res://Scripts/character.gd"

class_name NPC

var start_point = position
var leashing_distance = 700
@onready var player : Player = get_parent().get_node("Player")

enum NPC_STATES {WANDER, ATTACK, RETURN}
var state := NPC_STATES.WANDER :
	set(value):
		state = value
		if state == NPC_STATES.RETURN:
			return_to_home()
		elif state == NPC_STATES.ATTACK:
			attack_player()
		elif state == NPC_STATES.WANDER:
			wander()

func _ready():
	super()
	
	_wander()

	action_timer.timeout.connect(_wander)
	action_timer.start()
	
	circle_color = Color(.7, .1, .1)
	$SelectionArea.mouse_entered.connect(_on_mouse_over_mouse_entered)
	$SelectionArea.mouse_exited.connect(_on_mouse_over_mouse_exited)
	
	equip(Items.ITEM_NAME.leather)
	equip(Items.ITEM_NAME.mace)
	equip(Items.ITEM_NAME.buckler)

func _physics_process(delta) -> void:
	super(delta)
	if health <= 0:
		return
	
	var distance_to_start = position.distance_to(start_point)
		
	if distance_to_start > leashing_distance and state != NPC_STATES.RETURN:
		state = NPC_STATES.RETURN
	elif position.distance_to(player.position) < 300 and not (distance_to_start > 500 and target == null) and player.health > 0 and state != NPC_STATES.ATTACK:
		state = NPC_STATES.ATTACK
	elif distance_to_start < 100 and state != NPC_STATES.WANDER:
		state = NPC_STATES.WANDER
		
func return_to_home():
	$NavigationAgent2D.target_position = start_point
	animation_state.travel("Walk")
	target_animation_state = "Idle"
	action_timer.stop()
	target = null
	
func attack_player():
	if target == null:
		action_timer.timeout.disconnect(_wander)
		action_timer.timeout.connect(_fight)
		action_timer.start()
		
	target = player
	
func wander():
	action_timer.timeout.disconnect(_fight)
	action_timer.timeout.connect(_wander)
	action_timer.start()

func _update_state() -> void:
	pass
	
func set_selected(is_selected : bool) -> void:
	if is_selected:
		circle_color = UTILS.SELECTED_COLOR
	else:
		circle_color = UTILS.HOSTILE_COLOR
		

func _on_mouse_over_mouse_entered():
	GlobalCursor.mouse_enter(self)

func _on_mouse_over_mouse_exited():
	GlobalCursor.mouse_exit(self)

