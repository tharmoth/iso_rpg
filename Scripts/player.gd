extends "res://Scripts/character.gd"

func _update_state() -> void:
	if Input.is_action_just_pressed("interact") and animation_state.get_current_node() != "Death":
		$NavigationAgent2D.target_position = get_global_mouse_position()
		animation_state.travel("Walk")
		
		if GlobalCursor.current_state == GlobalCursor.State.ATTACK:
			target = GlobalCursor.selected
			target_animation_state = "Attack"
			fight_timer.start()
		else:
			target = null
			fight_timer.stop()
			
		if GlobalCursor.current_state == GlobalCursor.State.MOVE:
			target_animation_state = "Idle"
			
		if GlobalCursor.current_state == GlobalCursor.State.CAN_INTERACT or GlobalCursor.current_state == GlobalCursor.State.INTERACTING:
			target_animation_state = "Interact"
