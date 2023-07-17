extends RichTextLabel

var active_player : Player

func _ready():
	Party.party_leader_changed.connect(func(player): refresh())
	
func refresh():
	if active_player != null:
		active_player.rpg_character.equipment_changed.disconnect(update_text)
	active_player = Party.party_leader
	active_player.rpg_character.equipment_changed.connect(update_text)
	update_text(null, null)
	
func update_text(slot, item):
	text = active_player.rpg_character.print_stats(false)
