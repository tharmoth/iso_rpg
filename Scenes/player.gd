extends "res://Scenes/character.gd"

func _update_state() -> void:
	if Input.is_action_just_pressed("interact"):
		$NavigationAgent2D.target_position = get_global_mouse_position()
		animation_state.travel("Walk")
		
		if Cursor.current_state == CursorState.State.ATTACK:
			target_state = "Attack"
		elif Cursor.current_state == CursorState.State.MOVE:
			target_state = "Idle"
		elif Cursor.current_state == CursorState.State.CAN_INTERACT or Cursor.current_state == CursorState.State.INTERACTING:
			target_state = "Interact"

	if saved_state != animation_state.get_current_node():
		saved_state = animation_state.get_current_node()
		_on_state_change(saved_state)
