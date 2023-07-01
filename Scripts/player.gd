class_name Player extends BCharacter

var spawn = "default"
#@onready var scene = get_tree().current_scene.scene_file_path

func _update_healthbar():
#	GlobalPersistant.gui.get_node("%HealthBarCharacter1").value = MAX_HEALTH - health
#	GlobalPersistant.gui.get_node("%HealthTextCharacter1").text = str(health) + "/" +str(MAX_HEALTH)
	pass

func _ready():
	super()
	health_changed.connect(_update_healthbar)
	SPEED = 300
	
	equip(Items.ITEM_NAME.full_plate)
	equip(Items.ITEM_NAME.unarmed)
	
func _physics_process(delta):
	super(delta)
	_set_target()
	
func _set_target() -> void:
	if Input.is_action_just_pressed("interact"):
		target = get_global_mouse_position()
		
#		if GlobalCursor.current_state == GlobalCursor.State.ATTACK and target != GlobalCursor.selected:
#			target = GlobalCursor.selected
#		else:
#			target = null

#		if GlobalCursor.current_state == GlobalCursor.State.CAN_INTERACT or GlobalCursor.current_state == GlobalCursor.State.INTERACTING:
#			target_interactable = GlobalCursor.selected
#			target_animation_state = "Interact"
			
		
########################################
# Save related functions and variables #
########################################
func save():
	return {
		# Metadata
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
#		"scene" : get_tree().current_scene.scene_file_path,
		
		# Stats
		"health" : health,
		"position_x" : position.x,
		"position_y" : position.y,
		
		# Equipment
		"weapon" : weapon,
		"armor" : armor,
		"shield" : shield,
	}
