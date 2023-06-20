extends "res://Scripts/character.gd"

class_name NPC

var start_point = position
var leashing_distance = 700
@onready var player : Player = get_parent().get_node("Player")

func _ready():
	super()
	
	_wander()

	action_timer.timeout.disconnect(_fight)
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

	if distance_to_start > leashing_distance:
		$NavigationAgent2D.target_position = start_point
		animation_state.travel("Walk")
		action_timer.timeout.disconnect(_fight)
		action_timer.timeout.connect(_wander)
		action_timer.start()
		target = null
	elif position.distance_to(player.position) < 300 and not (distance_to_start > 500 and target == null):
		if target == null:
			action_timer.timeout.disconnect(_wander)
			action_timer.timeout.connect(_fight)
			action_timer.start()
			
		target = player
	else:
		target = null

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

