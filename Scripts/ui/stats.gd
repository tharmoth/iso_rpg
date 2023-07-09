extends RichTextLabel

var active_player : Player

func refresh():
	if active_player:
		active_player.rpg_character.equipment_changed.disconnect(update_text)
	active_player = GlobalPersistant.selected_player
	active_player.rpg_character.equipment_changed.connect(update_text)
	update_text(null, null)
	
func update_text(slot, item):
	text = active_player.rpg_character.print_stats(false)
