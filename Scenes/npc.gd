extends "res://Scenes/character.gd"

func _update_state() -> void:
	animation_state.travel("Idle")

func _on_mouse_over_mouse_entered():
	Cursor.current_state = CursorState.State.ATTACK

func _on_mouse_over_mouse_exited():
	Cursor.current_state = CursorState.State.MOVE
