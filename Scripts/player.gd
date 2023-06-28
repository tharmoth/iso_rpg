extends "res://Scripts/character.gd"

class_name Player

func _ready():
	super()
	var camera = Camera2D.new()
	camera.zoom = Vector2(1, 1)
	add_child(camera)
	
	action_timer.timeout.connect(_fight)
	
	if get_parent() is TileMap:
		var tilemap : TileMap = get_parent()
		tilemap.set_layer_modulate(0, Color(0, 0, 0, 0))
	
#	equip(Items.ITEM_NAME.farmer)
	damage = "20d20"
	GlobalCursor.player = self
	
	SPEED = 300

func _update_state() -> void:
	if Input.is_action_just_pressed("interact") and animation_state.get_current_node() != "Death":
		$NavigationAgent2D.target_position = get_global_mouse_position()
		animation_state.travel("Walk")
		
		if GlobalCursor.current_state == GlobalCursor.State.ATTACK and target != GlobalCursor.selected:
			target = GlobalCursor.selected
			target_animation_state = "Attack"
			action_timer.start()
		else:
			target = null
			action_timer.stop()
			
		if GlobalCursor.current_state == GlobalCursor.State.MOVE:
			target_animation_state = "Idle"
			
		if GlobalCursor.current_state == GlobalCursor.State.CAN_INTERACT or GlobalCursor.current_state == GlobalCursor.State.INTERACTING:
			target_interactable = GlobalCursor.selected
			target_animation_state = "Interact"
			
		
		_process_movement()
		steering._update_cache()
